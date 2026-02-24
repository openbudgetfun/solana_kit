import type {
  InstructionAccountNode,
  InstructionArgumentNode,
  InstructionNode,
} from "@codama/nodes";
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
import { camelCase, pascalCase } from "../utils/nameTransformers.js";
import { getDiscriminatorConstantsFragment } from "./discriminatorConstants.js";

/**
 * Generate a full Dart file for an instruction.
 */
export function getInstructionPageFragment(
  node: InstructionNode,
  scope: RenderScope,
): Fragment {
  const name = node.name as string;
  const typeName = scope.nameApi.dataType(name);
  const instrFnName = scope.nameApi.instructionFunction(name);
  const parseFnName = scope.nameApi.instructionParseFunction(name);

  const accounts = node.accounts ?? [];
  const args = (node.arguments ?? []).filter(
    (arg) => !isDiscriminatorArg(arg, node),
  );
  const allArgs = node.arguments ?? [];

  // Build the instruction data class
  const dataClassName = `${typeName}InstructionData`;

  // Data fields (non-discriminator arguments)
  const dataFieldDecls = allArgs
    .map((arg) => {
      const manifest = visit(arg.type, scope.typeManifestVisitor);
      const fieldName = camelCase(arg.name as string);
      return `  final ${manifest.type.content} ${fieldName};`;
    })
    .join("\n");

  const dataCtorParams = allArgs
    .map((arg) => {
      const fieldName = camelCase(arg.name as string);
      if (isDiscriminatorArg(arg, node)) {
        const manifest = visit(arg.type, scope.typeManifestVisitor);
        return `    this.${fieldName} = ${getDiscriminatorDefault(arg, node)},`;
      }
      return `    required this.${fieldName},`;
    })
    .join("\n");

  // Encoder/decoder for instruction data
  const encFields = allArgs
    .map((arg) => {
      const manifest = visit(arg.type, scope.typeManifestVisitor);
      return `    ('${arg.name as string}', ${manifest.encoder.content}),`;
    })
    .join("\n");

  const decFields = allArgs
    .map((arg) => {
      const manifest = visit(arg.type, scope.typeManifestVisitor);
      return `    ('${arg.name as string}', ${manifest.decoder.content}),`;
    })
    .join("\n");

  const toMapFields = allArgs
    .map(
      (arg) =>
        `      '${arg.name as string}': value.${camelCase(arg.name as string)},`,
    )
    .join("\n");

  const fromMapFields = allArgs
    .map((arg) => {
      const manifest = visit(arg.type, scope.typeManifestVisitor);
      return `      ${camelCase(arg.name as string)}: map['${arg.name as string}']! as ${manifest.type.content},`;
    })
    .join("\n");

  const dataEncoderName = `get${typeName}InstructionDataEncoder`;
  const dataDecoderName = `get${typeName}InstructionDataDecoder`;
  const dataCodecName = `get${typeName}InstructionDataCodec`;

  // Build the instruction builder function
  const accountParams = accounts
    .map((acc) => {
      const fieldName = camelCase(acc.name as string);
      const isRequired = !(acc.isOptional ?? false);
      return isRequired
        ? `  required Address ${fieldName},`
        : `  Address? ${fieldName},`;
    })
    .join("\n");

  const argParams = args
    .map((arg) => {
      const manifest = visit(arg.type, scope.typeManifestVisitor);
      const fieldName = camelCase(arg.name as string);
      const hasDefault = arg.defaultValue != null;
      if (hasDefault) {
        return `  ${manifest.type.content}? ${fieldName},`;
      }
      return `  required ${manifest.type.content} ${fieldName},`;
    })
    .join("\n");

  // Account metas
  const accountMetas = accounts
    .map((acc) => {
      const fieldName = camelCase(acc.name as string);
      const role = getAccountRole(acc);
      const isOptional = acc.isOptional ?? false;
      if (isOptional) {
        return `    if (${fieldName} != null) AccountMeta(address: ${fieldName}, role: ${role}),`;
      }
      return `    AccountMeta(address: ${fieldName}, role: ${role}),`;
    })
    .join("\n");

  // Instruction data construction
  const dataConstruction = allArgs
    .map((arg) => {
      const fieldName = camelCase(arg.name as string);
      if (isDiscriminatorArg(arg, node)) {
        return ""; // Use default
      }
      return `      ${fieldName}: ${fieldName}${arg.defaultValue != null ? ` ?? ${getDefaultValue(arg)}` : ""},`;
    })
    .filter(Boolean)
    .join("\n");

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
${use("Address", "solanaAddresses")}
${use("Instruction", "solanaInstructions")}
${use("AccountMeta", "solanaInstructions")}
${use("AccountRole", "solanaInstructions")}`,
  ];

  if (discFragment.content) parts.push(discFragment);

  // Data class
  parts.push(fragment`
@immutable
class ${fragmentFromString(dataClassName)} {
  const ${fragmentFromString(dataClassName)}({
${fragmentFromString(dataCtorParams)}
  });

${fragmentFromString(dataFieldDecls)}
}`);

  // Data encoder/decoder/codec
  parts.push(fragment`
Encoder<${fragmentFromString(dataClassName)}> ${fragmentFromString(dataEncoderName)}() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
${fragmentFromString(encFields)}
  ]);

  return transformEncoder(
    structEncoder,
    (${fragmentFromString(dataClassName)} value) => <String, Object?>{
${fragmentFromString(toMapFields)}
    },
  );
}

Decoder<${fragmentFromString(dataClassName)}> ${fragmentFromString(dataDecoderName)}() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
${fragmentFromString(decFields)}
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map) => ${fragmentFromString(dataClassName)}(
${fragmentFromString(fromMapFields)}
    ),
  );
}

Codec<${fragmentFromString(dataClassName)}, ${fragmentFromString(dataClassName)}> ${fragmentFromString(dataCodecName)}() {
  return combineCodec(${fragmentFromString(dataEncoderName)}(), ${fragmentFromString(dataDecoderName)}());
}`);

  // Instruction builder
  parts.push(fragment`
/// Creates a [${fragmentFromString(typeName)}] instruction.
Instruction ${fragmentFromString(instrFnName)}({
  required Address programAddress,
${fragmentFromString(accountParams)}
${fragmentFromString(argParams)}
}) {
  final data = ${fragmentFromString(dataClassName)}(
${fragmentFromString(dataConstruction)}
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
${fragmentFromString(accountMetas)}
    ],
    data: ${fragmentFromString(dataEncoderName)}().encode(data),
  );
}`);

  // Parse function
  parts.push(fragment`
/// Parses a [${fragmentFromString(typeName)}] instruction from raw instruction data.
${fragmentFromString(dataClassName)} ${fragmentFromString(parseFnName)}(Instruction instruction) {
  return ${fragmentFromString(dataDecoderName)}().decode(instruction.data!);
}`);

  return mergeFragments(parts, (cs) => cs.join("\n"));
}

function getAccountRole(acc: InstructionAccountNode): string {
  const isSigner = acc.isSigner === true || acc.isSigner === "either";
  const isWritable = acc.isWritable ?? false;

  if (isSigner && isWritable) return "AccountRole.signerWritable";
  if (isSigner) return "AccountRole.signerReadonly";
  if (isWritable) return "AccountRole.writable";
  return "AccountRole.readonly";
}

function isDiscriminatorArg(
  arg: InstructionArgumentNode,
  node: InstructionNode,
): boolean {
  const discriminators = node.discriminators ?? [];
  return discriminators.some(
    (d) =>
      d.kind === "fieldDiscriminatorNode" && d.name === arg.name,
  );
}

function getDiscriminatorDefault(
  arg: InstructionArgumentNode,
  _node: InstructionNode,
): string {
  if (arg.defaultValue) {
    if (arg.defaultValue.kind === "numberValueNode") {
      return String(arg.defaultValue.number);
    }
  }
  return "0";
}

function getDefaultValue(arg: InstructionArgumentNode): string {
  if (!arg.defaultValue) return "null";
  const dv = arg.defaultValue;
  switch (dv.kind) {
    case "numberValueNode":
      return String(dv.number);
    case "booleanValueNode":
      return String(dv.boolean);
    case "stringValueNode":
      return `'${dv.string}'`;
    case "publicKeyValueNode":
      return `Address('${dv.publicKey}')`;
    case "noneValueNode":
      return "null";
    default:
      return "null";
  }
}
