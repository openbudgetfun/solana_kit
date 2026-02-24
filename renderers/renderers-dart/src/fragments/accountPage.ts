import type { AccountNode, StructFieldTypeNode } from "@codama/nodes";
import { resolveNestedTypeNode } from "@codama/nodes";
import { visit } from "@codama/visitors-core";

import type { Fragment } from "../utils/fragment.js";
import {
  emptyFragment,
  fragment,
  fragmentFromString,
  mergeFragments,
  use,
} from "../utils/fragment.js";
import type { RenderScope } from "../utils/options.js";
import { camelCase } from "../utils/nameTransformers.js";
import { getDiscriminatorConstantsFragment } from "./discriminatorConstants.js";

/**
 * Generate a full Dart file for an account.
 */
export function getAccountPageFragment(
  node: AccountNode,
  scope: RenderScope,
): Fragment {
  const name = node.name as string;
  const typeName = scope.nameApi.dataType(name);
  const dataNode = resolveNestedTypeNode(node.data);

  // Fields from the struct data
  const fields = dataNode.fields;

  const fieldDecls = fields
    .map((f: StructFieldTypeNode) => {
      const manifest = visit(f.type, scope.typeManifestVisitor);
      return `  final ${manifest.type.content} ${camelCase(f.name as string)};`;
    })
    .join("\n");

  const ctorParams = fields
    .map((f: StructFieldTypeNode) => `    required this.${camelCase(f.name as string)},`)
    .join("\n");

  const eqChecks =
    fields.length === 0
      ? "true"
      : fields
          .map(
            (f: StructFieldTypeNode) =>
              `${camelCase(f.name as string)} == other.${camelCase(f.name as string)}`,
          )
          .join(" &&\n          ");

  const hashFields = fields
    .map((f: StructFieldTypeNode) => camelCase(f.name as string))
    .join(", ");

  const toStringFields = fields
    .map(
      (f: StructFieldTypeNode) =>
        `${camelCase(f.name as string)}: \$${camelCase(f.name as string)}`,
    )
    .join(", ");

  // Encoder fields
  const encFields = fields
    .map((f: StructFieldTypeNode) => {
      const manifest = visit(f.type, scope.typeManifestVisitor);
      return `    ('${f.name as string}', ${manifest.encoder.content}),`;
    })
    .join("\n");

  const decFields = fields
    .map((f: StructFieldTypeNode) => {
      const manifest = visit(f.type, scope.typeManifestVisitor);
      return `    ('${f.name as string}', ${manifest.decoder.content}),`;
    })
    .join("\n");

  const toMapFields = fields
    .map(
      (f: StructFieldTypeNode) =>
        `      '${f.name as string}': value.${camelCase(f.name as string)},`,
    )
    .join("\n");

  const fromMapFields = fields
    .map((f: StructFieldTypeNode) => {
      const manifest = visit(f.type, scope.typeManifestVisitor);
      return `      ${camelCase(f.name as string)}: map['${f.name as string}']! as ${manifest.type.content},`;
    })
    .join("\n");

  const encoderName = scope.nameApi.encoderFunction(name);
  const decoderName = scope.nameApi.decoderFunction(name);
  const codecName = scope.nameApi.codecFunction(name);
  const decodeFnName = scope.nameApi.accountDecodeFunction(name);

  // Size
  const sizeFragment = node.size != null
    ? fragment`
/// The size of the [${fragmentFromString(typeName)}] account data in bytes.
const int ${fragmentFromString(scope.nameApi.accountSizeConstant(name))} = ${fragmentFromString(String(node.size))};`
    : emptyFragment();

  // Discriminator
  const discFragment = getDiscriminatorConstantsFragment(node, scope);

  const parts: Fragment[] = [
    fragment`// Auto-generated. Do not edit.
// ignore_for_file: type=lint

${use("Uint8List", "dartTypedData")}
${use("immutable", "meta")}
${use("Encoder", "solanaCodecsCore")}
${use("Decoder", "solanaCodecsCore")}
${use("Codec", "solanaCodecsCore")}
${use("combineCodec", "solanaCodecsCore")}
${use("transformEncoder", "solanaCodecsCore")}
${use("transformDecoder", "solanaCodecsCore")}
${use("getStructEncoder", "solanaCodecsDataStructures")}
${use("getStructDecoder", "solanaCodecsDataStructures")}
${use("Account", "solanaAccounts")}
${use("EncodedAccount", "solanaAccounts")}
${use("decodeAccount", "solanaAccounts")}

@immutable
class ${fragmentFromString(typeName)} {
  const ${fragmentFromString(typeName)}({
${fragmentFromString(ctorParams)}
  });

${fragmentFromString(fieldDecls)}

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ${fragmentFromString(typeName)} &&
          runtimeType == other.runtimeType &&
          ${fragmentFromString(eqChecks)};

  @override
  int get hashCode => Object.hash(${fragmentFromString(hashFields)});

  @override
  String toString() => '${fragmentFromString(typeName)}(${fragmentFromString(toStringFields)})';
}`,
  ];

  if (sizeFragment.content) parts.push(sizeFragment);
  if (discFragment.content) parts.push(discFragment);

  parts.push(fragment`
Encoder<${fragmentFromString(typeName)}> ${fragmentFromString(encoderName)}() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
${fragmentFromString(encFields)}
  ]);

  return transformEncoder(
    structEncoder,
    (${fragmentFromString(typeName)} value) => <String, Object?>{
${fragmentFromString(toMapFields)}
    },
  );
}

Decoder<${fragmentFromString(typeName)}> ${fragmentFromString(decoderName)}() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
${fragmentFromString(decFields)}
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map) => ${fragmentFromString(typeName)}(
${fragmentFromString(fromMapFields)}
    ),
  );
}

Codec<${fragmentFromString(typeName)}, ${fragmentFromString(typeName)}> ${fragmentFromString(codecName)}() {
  return combineCodec(${fragmentFromString(encoderName)}(), ${fragmentFromString(decoderName)}());
}

Account<${fragmentFromString(typeName)}> ${fragmentFromString(decodeFnName)}(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, ${fragmentFromString(decoderName)}());
}`);

  return mergeFragments(parts, (cs) => cs.join("\n\n"));
}
