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

  // Visit each arg type once and collect manifests for reuse
  const allArgManifests = allArgs.map((arg) => ({
    arg,
    manifest: visit(arg.type, scope.typeManifestVisitor),
  }));

  // Data fields (non-discriminator arguments)
  const dataFieldDecls = allArgManifests
    .map(({ arg, manifest }) => {
      const fieldName = camelCase(arg.name as string);
      return `  final ${manifest.type.content} ${fieldName};`;
    })
    .join("\n");

  const dataCtorParams = allArgManifests
    .map(({ arg }) => {
      const fieldName = camelCase(arg.name as string);
      if (isDiscriminatorArg(arg, node)) {
        return `    this.${fieldName} = ${getDiscriminatorDefault(arg, node)},`;
      }
      return `    required this.${fieldName},`;
    })
    .join("\n");

  // Encoder/decoder for instruction data
  const encFields = allArgManifests
    .map(({ arg, manifest }) => {
      return `    ('${arg.name as string}', ${manifest.encoder.content}),`;
    })
    .join("\n");

  const decFields = allArgManifests
    .map(({ arg, manifest }) => {
      return `    ('${arg.name as string}', ${manifest.decoder.content}),`;
    })
    .join("\n");

  const toMapFields = allArgs
    .map(
      (arg) =>
        `      '${arg.name as string}': value.${camelCase(arg.name as string)},`,
    )
    .join("\n");

  const fromMapFields = allArgManifests
    .map(({ arg, manifest }) => {
      const typeStr = manifest.type.content;
      const isNullable = typeStr.endsWith("?");
      const accessor = isNullable ? `map['${arg.name as string}']` : `map['${arg.name as string}']!`;
      return `      ${camelCase(arg.name as string)}: ${accessor} as ${typeStr},`;
    })
    .join("\n");

  const dataEncoderName = `get${typeName}InstructionDataEncoder`;
  const dataDecoderName = `get${typeName}InstructionDataDecoder`;
  const dataCodecName = `get${typeName}InstructionDataCodec`;

  // Determine whether any arg or account name collides with 'programAddress'
  const argNames = new Set(args.map((a) => camelCase(a.name as string)));
  const accountNames = new Set(accounts.map((a) => camelCase(a.name as string)));
  const hasProgramAddressCollision = argNames.has('programAddress') || accountNames.has('programAddress');
  const instrProgramParam = hasProgramAddressCollision ? 'instructionProgramAddress' : 'programAddress';

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

  // Build argParams using manifests from the allArgManifests (filtered to non-discriminator args)
  const argManifestMap = new Map(allArgManifests.map(({ arg, manifest }) => [arg, manifest]));
  const argParams = args
    .map((arg) => {
      const manifest = argManifestMap.get(arg)!;
      const fieldName = camelCase(arg.name as string);
      const typeStr = manifest.type.content;
      const hasDefault = arg.defaultValue != null;
      if (hasDefault) {
        // Don't add `?` if the type is already nullable.
        const nullableType = typeStr.endsWith("?") ? typeStr : `${typeStr}?`;
        return `  ${nullableType} ${fieldName},`;
      }
      return `  required ${typeStr} ${fieldName},`;
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
      // Use 'arg_<name>' prefix to reference builder params without shadowing.
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
    (Map<String, Object?> map, Uint8List bytes, int offset) => ${fragmentFromString(dataClassName)}(
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
  required Address ${fragmentFromString(instrProgramParam)},
${fragmentFromString(accountParams)}
${fragmentFromString(argParams)}
}) {
  final instructionData = ${fragmentFromString(dataClassName)}(
${fragmentFromString(dataConstruction)}
  );

  return Instruction(
    programAddress: ${fragmentFromString(instrProgramParam)},
    accounts: [
${fragmentFromString(accountMetas)}
    ],
    data: ${fragmentFromString(dataEncoderName)}().encode(instructionData),
  );
}`);

  // Parse function
  parts.push(fragment`
/// Parses a [${fragmentFromString(typeName)}] instruction from raw instruction data.
${fragmentFromString(dataClassName)} ${fragmentFromString(parseFnName)}(Instruction instruction) {
  return ${fragmentFromString(dataDecoderName)}().decode(instruction.data!);
}`);

  const result = mergeFragments(parts, (cs) => cs.join("\n"));

  // Merge arg type manifest imports (encoder, decoder, type) into the result
  for (const { manifest } of allArgManifests) {
    result.imports.mergeWith(manifest.encoder.imports);
    result.imports.mergeWith(manifest.decoder.imports);
    result.imports.mergeWith(manifest.type.imports);
  }

  return result;
}

function getAccountRole(acc: InstructionAccountNode): string {
  const isSigner = acc.isSigner === true || acc.isSigner === "either";
  const isWritable = acc.isWritable ?? false;

  if (isSigner && isWritable) return "AccountRole.writableSigner";
  if (isSigner) return "AccountRole.readonlySigner";
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
