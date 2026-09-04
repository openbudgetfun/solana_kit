import assert from "node:assert/strict";
import * as fs from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { mock, test } from "node:test";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const originalToml = "[workspace]\nmembers = []\n";
const sourceMarker = '#![cfg_attr(feature = "stdsimd", feature(stdsimd))]\n';
let importId = 0;

/** Run the real builder against isolated files and inert external commands. */
async function runBuilder(t, options = {}) {
  const fixture = fs.mkdtempSync(join(tmpdir(), "artifact-builder-test-"));
  const fixtureRoot = join(fixture, "repo");
  const sharedTmp = join(fixture, "shared-tmp");
  const privateTmp = join(fixture, "private-tmp");
  const workspaceToml = join(fixtureRoot, ".repos/program/Cargo.toml");
  const victim = join(fixture, "victim.txt");
  const maliciousCrate = join(sharedTmp, "solana-kit-ahash-patch");
  const executions = [];
  const downloads = [];
  const builds = [];

  t.after(() => fs.rmSync(fixture, { recursive: true, force: true }));

  for (const directory of [
    join(fixtureRoot, "config/programs"),
    join(fixtureRoot, ".repos/program/.git"),
    join(fixtureRoot, ".repos/program/target/deploy"),
    sharedTmp,
    privateTmp,
  ]) {
    fs.mkdirSync(directory, { recursive: true });
  }

  fs.writeFileSync(workspaceToml, options.toml ?? originalToml);
  fs.writeFileSync(victim, "unrelated user file");
  fs.writeFileSync(join(fixtureRoot, "config/reference-repos.json"), JSON.stringify({
    repos: [{ name: "program", path: ".repos/program", ref: { value: "pinned" } }],
  }));
  fs.writeFileSync(join(fixtureRoot, "config/programs/artifacts.json"), JSON.stringify({
    artifacts: [{
      name: "test", version: "0.0.0", repo: "program", programDir: ".",
      crateName: "test", needsAhashPatch: options.needsAhashPatch ?? true,
      verifyProgramId: false,
    }],
  }));

  if (options.injectCrate) {
    fs.mkdirSync(maliciousCrate);
    fs.writeFileSync(join(maliciousCrate, "Cargo.toml"), '[package]\nname = "ahash"\nversion = "0.7.6"\n');
    fs.writeFileSync(join(maliciousCrate, "build.rs"), "attacker-controlled build script");
  }

  if (options.archiveSymlink) {
    fs.symlinkSync(victim, join(sharedTmp, "ahash-0.7.6.crate"));
  }

  // Remap only the script's real repository and historical shared paths.
  // This exercises the vulnerable paths without touching another user's /tmp.
  function mapPath(file) {
    if (file === root || file.startsWith(`${root}/`)) {
      return join(fixtureRoot, file.slice(root.length));
    }

    if (file === "/tmp/solana-kit-ahash-patch" || file.startsWith("/tmp/solana-kit-ahash-patch/")) {
      return join(sharedTmp, file.slice("/tmp/".length));
    }

    if (file === "/tmp/ahash-0.7.6.crate") {
      return join(sharedTmp, "ahash-0.7.6.crate");
    }

    return file;
  }

  const fileMethods = {};

  for (const name of ["existsSync", "mkdirSync", "mkdtempSync", "readFileSync", "rmSync", "writeFileSync"]) {
    fileMethods[name] = (file, ...args) => fs[name](mapPath(file), ...args);
  }

  const fsMock = mock.module("fs", { namedExports: fileMethods });
  const osMock = mock.module("os", { namedExports: { tmpdir: () => privateTmp } });
  const processMock = mock.module("child_process", {
    namedExports: {
      execFileSync(command, args) {
        if (command === "git") return;

        if (command === "curl") {
          const output = mapPath(args[args.indexOf("-o") + 1]);
          downloads.push(output);
          fs.writeFileSync(output, "downloaded crate archive");
          return;
        }

        if (command === "tar") {
          const destination = mapPath(args[args.indexOf("-C") + 1]);
          fs.mkdirSync(join(destination, "src"), { recursive: true });
          fs.writeFileSync(join(destination, "Cargo.toml"), '[package]\nname = "ahash"\nversion = "0.7.6"\n');
          fs.writeFileSync(join(destination, "src/lib.rs"), options.invalidSource ? "unexpected source" : `${sourceMarker}pub fn safe() {}\n`);
          return;
        }

        assert.equal(command, "cargo");
        assert.deepEqual(args, ["build-sbf"]);
        const manifest = fs.readFileSync(workspaceToml, "utf8");
        const patchPath = manifest.match(/ahash = \{ path = "([^"]+)" \}/)?.[1];

        if (patchPath) {
          const directory = mapPath(patchPath);
          const buildScript = join(directory, "build.rs");

          if (fs.existsSync(buildScript)) {
            executions.push(fs.readFileSync(buildScript, "utf8"));
          }

          builds.push({ directory, mode: fs.statSync(directory).mode & 0o777 });
        }

        if (options.failBuild) throw new Error("cargo build failed");

        fs.writeFileSync(join(fixtureRoot, ".repos/program/target/deploy/test.so"), "built artifact");
      },
    },
  });
  t.after(() => {
    processMock.restore();
    osMock.restore();
    fsMock.restore();
  });

  let error;

  try {
    await import(`./build_program_artifacts.mjs?case=${++importId}`);
  } catch (caught) {
    error = caught;
  }

  return { builds, downloads, error, executions, fixtureRoot, maliciousCrate, privateTmp, victim, workspaceToml };
}

test("a precreated shared ahash crate cannot supply Cargo build code", async (t) => {
  const result = await runBuilder(t, { injectCrate: true });

  assert.ifError(result.error);
  assert.deepEqual(result.executions, [], "Cargo consumed the attacker's precreated build.rs");
  assert.equal(result.downloads.length, 1);
  assert.equal(result.builds.length, 1);
  assert.equal(result.builds[0].mode, 0o700);
  assert.equal(fs.readFileSync(join(result.maliciousCrate, "build.rs"), "utf8"), "attacker-controlled build script");
});

test("a shared archive symlink cannot overwrite another user file", async (t) => {
  const result = await runBuilder(t, { archiveSymlink: true });

  assert.ifError(result.error);
  assert.equal(fs.readFileSync(result.victim, "utf8"), "unrelated user file");
  assert.equal(result.downloads.length, 1);
  assert.ok(result.downloads[0].startsWith(`${result.privateTmp}/`));
});

test("a successful build restores its manifest and removes temporary sources", async (t) => {
  const result = await runBuilder(t);

  assert.ifError(result.error);
  assert.equal(fs.readFileSync(result.workspaceToml, "utf8"), originalToml);
  assert.deepEqual(fs.readdirSync(result.privateTmp), []);
  assert.equal(fs.readFileSync(join(result.fixtureRoot, "config/programs/test-v0.0.0.so"), "utf8"), "built artifact");
});

test("a failed build restores its manifest and removes temporary sources", async (t) => {
  const result = await runBuilder(t, { failBuild: true });

  assert.match(result.error?.message ?? "", /cargo build failed/);
  assert.equal(fs.readFileSync(result.workspaceToml, "utf8"), originalToml);
  assert.deepEqual(fs.readdirSync(result.privateTmp), []);
});

test("invalid downloaded source is rejected and its temporary directory removed", async (t) => {
  const result = await runBuilder(t, { invalidSource: true });

  assert.match(result.error?.message ?? "", /ahash 0.7.6 source changed/);
  assert.deepEqual(result.builds, []);
  assert.equal(fs.readFileSync(result.workspaceToml, "utf8"), originalToml);
  assert.deepEqual(fs.readdirSync(result.privateTmp), []);
});

test("a build that does not need ahash leaves its manifest intact", async (t) => {
  const result = await runBuilder(t, { needsAhashPatch: false });

  assert.ifError(result.error);
  assert.deepEqual(result.downloads, []);
  assert.equal(fs.readFileSync(result.workspaceToml, "utf8"), originalToml);
});

test("an existing crates.io patch section is preserved", async (t) => {
  const toml = `${originalToml}\n[patch.crates-io]\n`;
  const result = await runBuilder(t, { toml });

  assert.ifError(result.error);
  assert.deepEqual(result.downloads, []);
  assert.equal(fs.readFileSync(result.workspaceToml, "utf8"), toml);
  assert.deepEqual(fs.readdirSync(result.privateTmp), []);
});
