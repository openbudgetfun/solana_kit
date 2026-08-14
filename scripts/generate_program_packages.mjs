#!/usr/bin/env node
// Generates Dart program packages from Codama IDLs using codama-renderers-dart.
// Usage: node scripts/generate_program_packages.mjs [--check] [--program=<repo>]
//   --check: only report which packages would change, don't write files
//   --program: only generate the package for the selected repository
import { readFileSync, existsSync, readdirSync } from "fs";
import { join, resolve } from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "..");
const RENDERER_DIR = resolve(ROOT, "packages/codama-renderers-dart");
const CHECK_ONLY = process.argv.includes("--check");
const PROGRAM_FILTER = process.argv
  .find((argument) => argument.startsWith("--program="))
  ?.slice("--program=".length);

// Import the renderer + visit from codama-renderers-dart's built dist
const { renderVisitor } = await import(join(RENDERER_DIR, "dist/index.node.js"));
const { visit } = await import(join(RENDERER_DIR, "node_modules/@codama/visitors-core/dist/index.node.mjs"));
const {
  accountNode,
  definedTypeLinkNode,
  definedTypeNode,
  instructionArgumentNode,
  numberTypeNode,
  structFieldTypeNode,
  structTypeNode,
} = await import(join(RENDERER_DIR, "node_modules/@codama/nodes/dist/index.node.mjs"));

const STAKE_ARGUMENT_TYPES = new Map([
  ["lockupArgs", "lockupParams"],
  ["lockupCheckedArgs", "lockupCheckedParams"],
  ["authorizeWithSeedArgs", "authorizeWithSeedParams"],
  ["authorizeCheckedWithSeedArgs", "authorizeCheckedWithSeedParams"],
]);

function prepareStakeRoot(root) {
  const program = root.program;
  const originalTypes = program.definedTypes ?? [];
  const typesByName = new Map(originalTypes.map((node) => [node.name, node]));
  const discriminatorType = numberTypeNode("u32");

  const definedTypes = [
    definedTypeNode({ name: "epoch", type: numberTypeNode("u64") }),
    definedTypeNode({ name: "unixTimestamp", type: numberTypeNode("i64") }),
    ...originalTypes.map((node) => {
      if (!["stakeState", "stakeStateV2"].includes(node.name)) {
        return node;
      }

      return { ...node, type: { ...node.type, size: discriminatorType } };
    }),
  ];

  const instructions = (program.instructions ?? [])
    .filter((node) => node.name !== "redelegate")
    .map((node) => ({
      ...node,
      optionalAccountStrategy: "omitted",
      arguments: node.arguments.flatMap((argument) => {
        if (argument.name === "discriminator") {
          return [{ ...argument, type: discriminatorType }];
        }

        const linkedName = argument.type.kind === "definedTypeLinkNode"
          ? argument.type.name
          : undefined;
        const replacementName = STAKE_ARGUMENT_TYPES.get(linkedName);
        if (replacementName == null) {
          return [argument];
        }

        const replacement = typesByName.get(replacementName);
        if (replacement?.type.kind !== "structTypeNode") {
          throw new Error(`Stake argument type ${replacementName} is not a struct`);
        }

        return replacement.type.fields.map((field) =>
          instructionArgumentNode({
            name: field.name,
            type: field.type,
            docs: field.docs,
          }),
        );
      }),
    }));

  const stakeAccount = accountNode({
    name: "stakeStateAccount",
    size: 200,
    data: structTypeNode([
      structFieldTypeNode({
        name: "state",
        type: definedTypeLinkNode("stakeStateV2"),
      }),
    ]),
  });

  return {
    ...root,
    program: {
      ...program,
      accounts: [...(program.accounts ?? []), stakeAccount],
      definedTypes,
      instructions,
    },
  };
}

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
  if (PROGRAM_FILTER != null && repo !== PROGRAM_FILTER) {
    continue;
  }

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
  const root = repo === "stake" ? prepareStakeRoot(idlJson) : idlJson;

  if (CHECK_ONLY) {
    console.log(`  (check-only) Would render to ${outDir}`);
    continue;
  }

  try {
    visit(root, renderVisitor(outDir, {
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