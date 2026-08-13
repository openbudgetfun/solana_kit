#!/usr/bin/env node
// Generates Dart program packages from Codama IDLs using codama-renderers-dart.
// Usage: node scripts/generate_program_packages.cjs
const { readFileSync, existsSync } = require("fs");
const { join, resolve } = require("path");

const ROOT = resolve(__dirname, "..");
const R = join(ROOT, "packages/codama-renderers-dart");
const { renderVisitor } = require(join(R, "dist/index.node.cjs"));
const { visit } = require(join(R, "node_modules/@codama/visitors-core/dist/index.node.cjs"));
const { rootNodeFromAnchor } = require(join(R, "node_modules/@codama/nodes-from-anchor/dist/index.node.cjs"));

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

  if (!existsSync(idlPath)) { console.error(`SKIP: IDL not found: ${idlPath}`); continue; }
  if (!existsSync(pkgDir)) { console.error(`SKIP: Package not found: ${pkgDir}`); continue; }

  console.log(`Generating ${pkg} from ${repo}...`);
  const idlJson = JSON.parse(readFileSync(idlPath, "utf-8"));

  // Convert Anchor-format IDLs to Codama root nodes
  let rootNode;
  if (idlJson.kind === "rootNode") {
    rootNode = idlJson; // Already Codama format
  } else {
    console.log("  Converting from Anchor format...");
    rootNode = rootNodeFromAnchor(idlJson);
  }

  try {
    visit(rootNode, renderVisitor(outDir, {
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