import type { PdaNode } from "@codama/nodes";
import { visit } from "@codama/visitors-core";

import type { Fragment } from "../utils/fragment.js";
import {
  fragment,
  fragmentFromString,
  mergeFragments,
  use,
} from "../utils/fragment.js";
import type { RenderScope } from "../utils/options.js";
import { camelCase, pascalCase } from "../utils/nameTransformers.js";

/**
 * Generate a full Dart file for a PDA.
 */
export function getPdaPageFragment(
  node: PdaNode,
  scope: RenderScope,
): Fragment {
  const name = node.name as string;
  const findFnName = scope.nameApi.pdaFindFunction(name);
  const seedsClassName = `${pascalCase(name)}Seeds`;

  const seeds = node.seeds ?? [];

  // Separate variable seeds from constant seeds
  const variableSeeds = seeds.filter(
    (s) => s.kind === "variablePdaSeedNode",
  );
  const constantSeeds = seeds.filter(
    (s) => s.kind === "constantPdaSeedNode",
  );

  // Build seeds class if there are variable seeds
  const hasSeedsClass = variableSeeds.length > 0;

  const seedFieldDecls = variableSeeds
    .map((s) => {
      if (s.kind !== "variablePdaSeedNode") return "";
      const manifest = visit(s.type, scope.typeManifestVisitor);
      return `  final ${manifest.type.content} ${camelCase(s.name as string)};`;
    })
    .join("\n");

  const seedCtorParams = variableSeeds
    .map((s) => {
      if (s.kind !== "variablePdaSeedNode") return "";
      return `    required this.${camelCase(s.name as string)},`;
    })
    .join("\n");

  // Build the seed bytes list
  const seedBytesList: string[] = [];
  for (const seed of seeds) {
    if (seed.kind === "constantPdaSeedNode") {
      if (seed.value.kind === "bytesValueNode") {
        seedBytesList.push(`    ...${bytesValueToDart(seed.value.data)},`);
      } else if (seed.value.kind === "stringValueNode") {
        seedBytesList.push(`    ...utf8.encode('${seed.value.string}'),`);
      } else if (seed.value.kind === "publicKeyValueNode") {
        seedBytesList.push(`    ...getAddressEncoder().encode(Address('${seed.value.publicKey}')),`);
      } else if (seed.value.kind === "numberValueNode") {
        const manifest = visit(seed.type, scope.typeManifestVisitor);
        seedBytesList.push(`    ...${manifest.encoder.content}.encode(${seed.value.number}),`);
      }
    } else if (seed.kind === "variablePdaSeedNode") {
      const manifest = visit(seed.type, scope.typeManifestVisitor);
      seedBytesList.push(
        `    ...${manifest.encoder.content}.encode(seeds.${camelCase(seed.name as string)}),`,
      );
    }
  }

  // Program address parameter
  const programIdParam = node.programId
    ? `Address programAddress = const Address('${node.programId}')`
    : "required Address programAddress";

  const parts: Fragment[] = [
    fragment`// Auto-generated. Do not edit.
// ignore_for_file: type=lint

${use("Uint8List", "dartTypedData")}
${use("immutable", "meta")}
${use("Address", "solanaAddresses")}
${use("getAddressEncoder", "solanaAddresses")}`,
  ];

  if (hasSeedsClass) {
    parts.push(fragment`
@immutable
class ${fragmentFromString(seedsClassName)} {
  const ${fragmentFromString(seedsClassName)}({
${fragmentFromString(seedCtorParams)}
  });

${fragmentFromString(seedFieldDecls)}
}`);
  }

  const seedsParam = hasSeedsClass ? `  required ${seedsClassName} seeds,` : "";

  parts.push(fragment`
/// Finds the program derived address for [${fragmentFromString(pascalCase(name))}].
Future<(Address, int)> ${fragmentFromString(findFnName)}({
${fragmentFromString(seedsParam)}
  ${fragmentFromString(programIdParam)},
}) async {
  final seedBytes = <int>[
${fragmentFromString(seedBytesList.join("\n"))}
  ];

  // TODO: Call getProgramDerivedAddress with seedBytes and programAddress
  throw UnimplementedError('PDA derivation not yet implemented');
}`);

  return mergeFragments(parts, (cs) => cs.join("\n"));
}

function bytesValueToDart(hex: string): string {
  const clean = hex.replace(/^0x/, "");
  const pairs: string[] = [];
  for (let i = 0; i < clean.length; i += 2) {
    pairs.push(`0x${clean.slice(i, i + 2)}`);
  }
  return `[${pairs.join(", ")}]`;
}
