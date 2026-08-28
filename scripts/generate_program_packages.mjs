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

// Stake instruction arguments carry a discriminated struct payload. Older
// IDL revisions linked these arguments under *Args names that shadowed the
// shared params types; js@v0.9.0 (Codama v1.8.0 format) links the params
// types directly. Both link names are mapped so the instruction arguments
// stay flattened into their parameter fields for either IDL revision.
const STAKE_ARGUMENT_TYPES = new Map([
  ["lockupArgs", "lockupParams"],
  ["lockupCheckedArgs", "lockupCheckedParams"],
  ["authorizeWithSeedArgs", "authorizeWithSeedParams"],
  ["authorizeCheckedWithSeedArgs", "authorizeCheckedWithSeedParams"],
  ["lockupParams", "lockupParams"],
  ["lockupCheckedParams", "lockupCheckedParams"],
  ["authorizeWithSeedParams", "authorizeWithSeedParams"],
  ["authorizeCheckedWithSeedParams", "authorizeCheckedWithSeedParams"],
]);

// Shank emits `Vec<crate::state::RelationshipEntry>` in the mpl-core IDL with
// the defined-type name collapsed to `"crate"`. The real type is the
// `RelationshipEntry` defined type, so rewrite the reference before rendering.
function prepareMplCoreRoot(root) {
  const rewritten = JSON.parse(
    JSON.stringify(root).replaceAll('"defined":"crate"', '"defined":"relationshipEntry"'),
  );
  return rewritten;
}

// UpdateMetadataAccountV2 has both an `updateAuthority` account and an
// `UpdateMetadataAccountArgsV2.updateAuthority` argument. The upstream TS SDK
// renames the argument to `newUpdateAuthority`; mirror that so the generated
// Dart instruction signature does not collide.
function prepareMplTokenMetadataRoot(root) {
  let renamed = 0;
  const visit = (node) => {
    if (Array.isArray(node)) {
      node.forEach(visit);
      return;
    }
    if (node == null || typeof node !== "object") return;
    if (
      node.name === "updateAuthority" &&
      JSON.stringify(node.type) === JSON.stringify({ option: "publicKey" })
    ) {
      node.name = "newUpdateAuthority";
      renamed += 1;
      return;
    }
    Object.values(node).forEach(visit);
  };
  visit(root);
  // Exactly two fields match: UpdateMetadataAccountArgsV2 and the deprecated
  // UpdateMetadataAccountV1 args struct. Renaming both mirrors the upstream
  // TS SDK, which exposes `newUpdateAuthority` for both.
  if (renamed !== 2) {
    throw new Error(
      `prepareMplTokenMetadataRoot: expected 2 updateAuthority fields, renamed ${renamed}`,
    );
  }
  return root;
}

// Squads v4's MultisigSetConfigAuthorityArgs uses a `configAuthority` field
// while the instruction also has a `configAuthority` account. The upstream TS
// SDK renames the argument to `newConfigAuthority`; mirror that so the
// generated Dart instruction signature does not collide.
function prepareSquadsMultisigRoot(root) {
  const typeNames = new Set();
  const collectTypeNames = (node) => {
    if (Array.isArray(node)) {
      node.forEach(collectTypeNames);
    } else if (node != null && typeof node === "object") {
      if (typeof node.name === "string") typeNames.add(node.name);
      Object.values(node).forEach(collectTypeNames);
    }
  };
  collectTypeNames(root.types ?? []);

  let renamed = 0;
  const visit = (node, parentTypeName) => {
    if (Array.isArray(node)) {
      node.forEach((child) => visit(child, parentTypeName));
      return;
    }
    if (node == null || typeof node !== "object") return;
    if (
      node.name === "configAuthority" &&
      parentTypeName === "MultisigSetConfigAuthorityArgs"
    ) {
      node.name = "newConfigAuthority";
      renamed += 1;
      return;
    }
    const childParentTypeName =
      typeof node.name === "string" && node.type != null
        ? node.name
        : parentTypeName;
    Object.values(node).forEach((child) => visit(child, childParentTypeName));
  };
  visit(root, undefined);
  if (renamed !== 1) {
    throw new Error(
      `prepareSquadsMultisigRoot: expected 1 configAuthority field, renamed ${renamed}`,
    );
  }
  return root;
}

function prepareStakeRoot(root) {
  // Upstream renamed the IDL program node from "solanaStakeInterface" to
  // "stake" when it moved to the Codama v1.8.0 format (js@v0.9.0). The
  // program name drives every rendered identifier and barrel file name, so
  // keep the previous name to avoid a wholesale generated-API rename with no
  // wire-format change.
  const program = { ...root.program, name: "solanaStakeInterface" };
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
//
// Entries without `idlPath` read `.repos/solana-program/<repo>/idl.json`,
// which is a Codama-native root node. Entries with `idlPath` point at an
// Anchor/shank-format IDL that is converted with @codama/nodes-from-anchor
// first; `programName` pins the renderer-facing program name so generated
// identifiers and barrel files stay stable across upstream regeneration.
const PROGRAMS = [
  { repo: "system",              pkg: "solana_kit_system" },
  { repo: "token",               pkg: "solana_kit_token" },
  { repo: "token-2022",          pkg: "solana_kit_token_2022" },
  { repo: "address-lookup-table", pkg: "solana_kit_address_lookup_table" },
  { repo: "memo",                pkg: "solana_kit_memo" },
  { repo: "compute-budget",       pkg: "solana_kit_compute_budget" },
  { repo: "stake",               pkg: "solana_kit_stake" },
  { repo: "loader-v3",           pkg: "solana_kit_loader" },
  {
    repo: "mpl-token-metadata",
    pkg: "solana_kit_mpl_token_metadata",
    idlPath: ".repos/metaplex-foundation/mpl-token-metadata/idls/token_metadata.json",
    programName: "mpl_token_metadata",
  },
  {
    repo: "mpl-core",
    pkg: "solana_kit_mpl_core",
    idlPath: ".repos/metaplex-foundation/mpl-core/idls/mpl_core.json",
    programName: "mpl_core",
  },
  {
    repo: "squads-multisig",
    pkg: "solana_kit_squads",
    idlPath: ".repos/Squads-Protocol/v4/sdk/multisig/idl/squads_multisig_program.json",
    programName: "squads_multisig",
  },
];

for (const { repo, pkg, idlPath: idlPathOverride, programName } of PROGRAMS) {
  if (PROGRAM_FILTER != null && repo !== PROGRAM_FILTER) {
    continue;
  }

  const idlPath = join(ROOT, idlPathOverride ?? `.repos/solana-program/${repo}/idl.json`);
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
  let root;
  if (idlJson.kind === "rootNode") {
    root = repo === "stake" ? prepareStakeRoot(idlJson) : idlJson;
  } else {
    // Anchor/shank-format IDL: pin the renderer-facing program name, then
    // convert with @codama/nodes-from-anchor.
    const { rootNodeFromAnchor } = await import(
      join(RENDERER_DIR, "node_modules/@codama/nodes-from-anchor/dist/index.node.mjs")
    );
    if (programName != null) {
      idlJson.name = programName;
    }
    if (repo === "mpl-core") {
      const fixed = prepareMplCoreRoot(idlJson);
      root = rootNodeFromAnchor(fixed);
    } else if (repo === "mpl-token-metadata") {
      const fixed = prepareMplTokenMetadataRoot(idlJson);
      root = rootNodeFromAnchor(fixed);
    } else if (repo === "squads-multisig") {
      const fixed = prepareSquadsMultisigRoot(idlJson);
      root = rootNodeFromAnchor(fixed);
    } else {
      root = rootNodeFromAnchor(idlJson);
    }
  }

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