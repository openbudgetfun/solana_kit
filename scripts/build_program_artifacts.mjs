#!/usr/bin/env node
// Builds the committed Solana program artifacts (`.so`) with `cargo build-sbf`
// from the pinned reference repos, so the on-chain integration tests deploy
// reproducible binaries built from source (not opaque mainnet downloads).
//
// Usage: node scripts/build_program_artifacts.mjs [--program=<name>]
//   --program: only build the artifact for the selected program (e.g. bubblegum)
//
// Reads:
//   - config/reference-repos.json  -> repo paths + pinned refs
//   - config/programs/artifacts.json -> artifact metadata (name, version, dir, ID)
//
// Writes:
//   - config/programs/<name>-v<version>.so
//
// Requires: `cargo build-sbf` on PATH (provided by the devenv `agave` package).
import { execFileSync } from "child_process";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "fs";
import { tmpdir } from "os";
import { join, resolve } from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "..");
const ARTIFACTS_DIR = join(ROOT, "config/programs");

const PROGRAM_FILTER = process.argv
  .find((argument) => argument.startsWith("--program="))
  ?.slice("--program=".length);

const referenceRepos = JSON.parse(
  readFileSync(join(ROOT, "config/reference-repos.json"), "utf8"),
).repos;
const { artifacts } = JSON.parse(
  readFileSync(join(ARTIFACTS_DIR, "artifacts.json"), "utf8"),
);

function run(command, args, options = {}) {
  console.log(`$ ${command} ${args.join(" ")}`);
  return execFileSync(command, args, {
    stdio: "inherit",
    cwd: ROOT,
    ...options,
  });
}

function repoFor(name) {
  const repo = referenceRepos.find((entry) => entry.name === name);
  if (!repo) throw new Error(`No reference repo named "${name}" in config/reference-repos.json`);
  return repo;
}

function checkoutPin(repo) {
  const path = join(ROOT, repo.path);
  if (!existsSync(join(path, ".git"))) {
    console.log(`Cloning ${repo.url} -> ${path}`);
    mkdirSync(dirname(path), { recursive: true });
    run("git", ["clone", "--quiet", repo.url, path]);
  }
  const ref = repo.ref.value;
  console.log(`Checking out ${repo.name} @ ${ref}`);
  run("git", ["-C", path, "fetch", "--quiet", "origin", ref], { stdio: "pipe" });
  run("git", ["-C", path, "checkout", "--quiet", ref]);
}

// The platform-tools rustc (1.89+) removed the `stdsimd` feature gate, but
// agave's `cargo build-sbf` still injects `--cfg feature="stdsimd"` for AES-NI
// hashing. Older Solana programs pull in ahash releases whose
// `#![cfg_attr(feature = "stdsimd", feature(stdsimd))]` then fails with E0635.
// The actual stdsimd code is ARM/AArch64-gated (inert on SBF), so removing the
// gate line is safe. We vendor a patched ahash and wire it via [patch.crates-io].
function applyAhashPatch(repo, artifact, patchDir) {
  const workspaceToml = join(ROOT, repo.path, artifact.workspaceToml ?? "Cargo.toml");
  const toml = readFileSync(workspaceToml, "utf8");
  if (toml.includes("[patch.crates-io]")) return; // already patched

  const ahashVersions = artifact.ahashVersions ?? [artifact.ahashVersion ?? "0.7.6"];
  const marker = '#![cfg_attr(feature = "stdsimd", feature(stdsimd))]\n';
  const patches = [];

  for (const ahashVersion of ahashVersions) {
    console.log(`Preparing patched ahash ${ahashVersion} (removes the removed \`stdsimd\` feature gate)`);
    const crate = join(patchDir, `ahash-${ahashVersion}.crate`);
    const sourceDir = join(patchDir, `ahash-${ahashVersion}`);
    mkdirSync(sourceDir, { recursive: true, mode: 0o700 });
    run("curl", ["-fsSL", "-A", "solana-kit-build-script", `https://static.crates.io/crates/ahash/ahash-${ahashVersion}.crate`, "-o", crate]);
    run("tar", ["-xzf", crate, "-C", sourceDir, "--strip-components=1"]);
    const lib = join(sourceDir, "src/lib.rs");
    const source = readFileSync(lib, "utf8");

    if (!source.includes(marker)) throw new Error(`ahash ${ahashVersion} source changed; re-check the patch`);

    writeFileSync(lib, source.replace(marker, ""));
    const patchName = `ahash_${ahashVersion.replaceAll(".", "_")}`;
    patches.push(`${patchName} = { package = "ahash", path = "${sourceDir}" }`);
  }

  writeFileSync(workspaceToml, `${toml}\n[patch.crates-io]\n${patches.join("\n")}\n`);

  return () => writeFileSync(workspaceToml, toml);
}

function buildArtifact(artifact) {
  const repo = repoFor(artifact.repo);
  checkoutPin(repo);
  let patchDir;
  let restoreWorkspace;
  let restoreLockfile;

  const programDir = join(ROOT, repo.path, artifact.programDir);
  const workspaceToml = artifact.workspaceToml ?? "Cargo.toml";
  const workspaceRoot = join(ROOT, repo.path, dirname(workspaceToml));
  const lockfile = join(workspaceRoot, "Cargo.lock");
  console.log(`Building ${artifact.name} (${artifact.crateName}) with cargo build-sbf...`);

  try {
    if (artifact.needsAhashPatch) {
      // Private, unpredictable paths prevent another user from supplying a
      // Cargo dependency or redirecting the archive download through a symlink.
      patchDir = mkdtempSync(join(tmpdir(), "solana-kit-ahash-"));
      restoreWorkspace = applyAhashPatch(repo, artifact, patchDir);
    }

    if (artifact.cargoUpdates?.length) {
      const originalLockfile = readFileSync(lockfile);
      restoreLockfile = () => writeFileSync(lockfile, originalLockfile);
      for (const update of artifact.cargoUpdates) {
        run("cargo", ["update", "-p", update.package, "--precise", update.version], {
          cwd: programDir,
        });
      }
    }

    execFileSync("cargo", ["build-sbf"], {
      stdio: "inherit",
      cwd: programDir,
      env: artifact.blake3Pure
        ? { ...process.env, CARGO_FEATURE_PURE: "1" }
        : process.env,
    });
  } finally {
    try {
      restoreLockfile?.();
    } finally {
      try {
        restoreWorkspace?.();
      } finally {
        if (patchDir) rmSync(patchDir, { recursive: true, force: true });
      }
    }
  }

  // cargo build-sbf writes to <rust-workspace-root>/target/deploy/<crate>.so
  const built = join(workspaceRoot, "target/deploy", `${artifact.crateName}.so`);
  if (!existsSync(built)) throw new Error(`Expected built artifact at ${built}`);

  const target = join(ARTIFACTS_DIR, `${artifact.name}-v${artifact.version}.so`);
  writeFileSync(target, readFileSync(built));
  console.log(`Wrote ${target} (${readFileSync(built).length} bytes)`);

  if (artifact.verifyProgramId !== false) {
    verifyProgramId(target, artifact.programId);
  }
}

// The program ID is baked into the binary via declare_id!; verify the 32-byte
// pubkey is present so PDA derivation works when deployed at the canonical ID.
function verifyProgramId(path, programId) {
  const ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
  let n = 0n;
  for (const char of programId) n = n * 58n + BigInt(ALPHABET.indexOf(char));
  const bytes = Buffer.from(n.toString(16).padStart(64, "0"), "hex");
  const data = readFileSync(path);
  if (!data.includes(bytes)) {
    throw new Error(`Program ID ${programId} not found in ${path}`);
  }
  console.log(`Verified program ID ${programId} in ${path}`);
}

const selected = artifacts.filter(
  (artifact) => !PROGRAM_FILTER || artifact.name === PROGRAM_FILTER,
);
if (selected.length === 0) {
  throw new Error(`No artifact named "${PROGRAM_FILTER}" in config/programs/artifacts.json`);
}

for (const artifact of selected) {
  buildArtifact(artifact);
}
console.log(`\nBuilt ${selected.length} artifact(s) into ${ARTIFACTS_DIR}`);
