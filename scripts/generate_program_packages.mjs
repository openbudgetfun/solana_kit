#!/usr/bin/env node
// Generates Dart program packages from Codama IDLs using codama-renderers-dart.
// Usage: node scripts/generate_program_packages.mjs [--check]
//   --check: only report which packages would change, don't write files
import { readFileSync, existsSync, readdirSync } from "fs";
import { join, resolve } from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "..");
const RENDERER_DIR = resolve(ROOT, "packages/codama-renderers-dart");
const CHECK_ONLY = process.argv.includes("--check");

// Import the renderer + visit from codama-renderers-dart's built dist
const { renderVisitor } = await import(join(RENDERER_DIR, "dist/index.node.js"));
const { visit } = await import(join(RENDERER_DIR, "node_modules/@codama/visitors-core/dist/index.js"));

// Map: repo-name → { idlPath, outputDir, packageDir }
const PROGRAMS = [
  { repo: "system",              pkg: "solana_kit_system" },
  { repo: "token",               pkg: "solana_kit_token" },
  { repo: "token-2022",          pkg: "solana_kit_token_2022" },
  { repo: "address-lookup-table", pkg: "solana_kit_address_lookup_table" },
  { repo: "memo",                pkg: "solana_kit_memo" },
  { repo: "compute-budget",       pkg: "solana_kit_compute_budget" },
  { repo: "stake",               pkg: "solana_kit_stake" },
  { repo: "loader-v3",           pkg: "solana_kit_loader" },
];

for (const { repo, pkg } of PROGRAMS) {
  const idlPath = join(ROOT, `.repos/solana-program/${repo}/idl.json`);
  const pkgDir = join(ROOT, "packages", pkg);
  const outDir = join(pkgDir, "lib/src/generated");

  if (!existsSync(idlPath)) {
    console.error(`SKIP: IDL not found: ${idlPath}`);
    continue;
  }
  if (!existsSync(pkgDir)) {
    console.error(`SKIP: Package not found: ${pkgDir}`);
    continue;
  }

  console.log(`Generating ${pkg} from ${repo}...`);
  const idlJson = JSON.parse(readFileSync(idlPath, "utf-8"));

  if (CHECK_ONLY) {
    console.log(`  (check-only) Would render to ${outDir}`);
    continue;
  }

  try {
    visit(idlJson, renderVisitor(outDir, {
      formatCode: true,
      deleteFolderBeforeRendering: true,
    }));
    console.log(`  ✓ ${pkg} generated to ${outDir}`);
  } catch (e) {
    console.error(`  ✗ ${pkg} FAILED: ${e.message}`);
    if (e.stack) console.error(e.stack.split("\n").slice(0, 5).join("\n"));
  }
}
console.log("Done.");