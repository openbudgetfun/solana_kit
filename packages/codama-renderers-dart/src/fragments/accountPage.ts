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
import { getDiscriminatorValidationFragment } from "../utils/discriminators.js";
import { getExactDecoderFragment } from "../utils/exactDecoder.js";
import {
  getDartValueFragment,
  isConstDartValueNode,
} from "../utils/valueNodes.js";
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
  // Fields from the struct data
  const fields = resolveNestedTypeNode(node.data).fields ?? [];

  // Visit each field type once and collect manifests for reuse
  const fieldManifests = fields.map((f: StructFieldTypeNode) => ({
    field: f,
    manifest: visit(f.type, scope.typeManifestVisitor),
  }));

  const omittedFields = fields.filter(isOmittedDefaultField);
  const constructorFields = fields.filter(
    (field) => !isOmittedDefaultField(field),
  );
  const forcedFields = new Set([
    ...omittedFields,
    ...fields.filter((field) => isFieldDiscriminator(field, node)),
  ]);
  const fieldDefaults = new Map(
    fieldManifests.flatMap(({ field, manifest }) => {
      if (!forcedFields.has(field) || field.defaultValue == null) return [];
      return [
        [
          field,
          getDartValueFragment(field.defaultValue, manifest.type.content),
        ] as const,
      ];
    }),
  );

  for (const field of forcedFields) {
    if (!fieldDefaults.has(field)) {
      throw new Error(
        `Forced field "${field.name}" on account "${node.name}" must have a deterministic default value.`,
      );
    }
  }

  const fieldDecls = fieldManifests
    .map(({ field: f, manifest }) => {
      return `  final ${manifest.type.content} ${camelCase(f.name as string)};`;
    })
    .join("\n");

  const ctorParams = constructorFields
    .map((f: StructFieldTypeNode) => `    required this.${camelCase(f.name as string)},`)
    .join("\n");

  const ctorInitializers = omittedFields
    .map((field) => {
      const fieldName = camelCase(field.name as string);
      return `${fieldName} = ${fieldDefaults.get(field)!.content}`;
    })
    .join(",\n      ");

  // Empty structs use a no-arg constructor; `const Foo({})` is invalid Dart.
  const ctorKeyword = omittedFields.every((field) =>
    isConstDartValueNode(field.defaultValue!),
  )
    ? "const "
    : "";
  const ctorSignature = constructorFields.length === 0
    ? `${ctorKeyword}${typeName}()${ctorInitializers ? ` : ${ctorInitializers}` : ""};`
    : `${ctorKeyword}${typeName}({\n${ctorParams}\n  })${ctorInitializers ? ` :\n      ${ctorInitializers}` : ""};`;

  const eqChecks =
    fields.length === 0
      ? "true"
      : fields
          .map(
            (f: StructFieldTypeNode) =>
              `${camelCase(f.name as string)} == other.${camelCase(f.name as string)}`,
          )
          .join(" &&\n          ");

  const hashFieldNames = fields.map((f: StructFieldTypeNode) => camelCase(f.name as string));
  // `Object.hash()` requires at least two arguments, so handle 0/1 fields specially.
  const hashCodeExpr =
    hashFieldNames.length === 0
      ? "0"
      : hashFieldNames.length === 1
        ? `${hashFieldNames[0]}.hashCode`
        : `Object.hash(${hashFieldNames.join(", ")})`;

  const toStringFields = fields
    .map(
      (f: StructFieldTypeNode) =>
        `${camelCase(f.name as string)}: \$${camelCase(f.name as string)}`,
    )
    .join(", ");

  // Encoder fields
  const encFields = fieldManifests
    .map(({ field: f, manifest }) => {
      return `    ('${f.name as string}', ${manifest.encoder.content}),`;
    })
    .join("\n");

  const decFields = fieldManifests
    .map(({ field: f, manifest }) => {
      return `    ('${f.name as string}', ${manifest.decoder.content}),`;
    })
    .join("\n");

  const toMapFields = fields
    .map((f: StructFieldTypeNode) => {
      const value = forcedFields.has(f)
        ? fieldDefaults.get(f)!.content
        : `value.${camelCase(f.name as string)}`;
      return `      '${f.name as string}': ${value},`;
    })
    .join("\n");

  const fromMapFields = fieldManifests
    .filter(({ field }) => !isOmittedDefaultField(field))
    .map(({ field: f, manifest }) => {
      const typeStr = manifest.type.content;
      const isNullable = typeStr.endsWith("?");
      const accessor = isNullable ? `map['${f.name as string}']` : `map['${f.name as string}']!`;
      return `      ${camelCase(f.name as string)}: ${accessor} as ${typeStr},`;
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
  const discriminatorValidation = getDiscriminatorValidationFragment(
    node,
    scope,
  );
  const exactDecoder = getExactDecoderFragment({
    typeName,
    description: `${name} account decoder`,
    discriminatorValidation,
    fromMapFields,
  });

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
  ${fragmentFromString(ctorSignature)}

${fragmentFromString(fieldDecls)}

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ${fragmentFromString(typeName)} &&
          runtimeType == other.runtimeType &&
          ${fragmentFromString(eqChecks)};

  @override
  int get hashCode => ${fragmentFromString(hashCodeExpr)};

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

${exactDecoder}
}

Codec<${fragmentFromString(typeName)}, ${fragmentFromString(typeName)}> ${fragmentFromString(codecName)}() {
  return combineCodec(${fragmentFromString(encoderName)}(), ${fragmentFromString(decoderName)}());
}

Account<${fragmentFromString(typeName)}> ${fragmentFromString(decodeFnName)}(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, ${fragmentFromString(decoderName)}());
}`);

  const result = mergeFragments(parts, (cs) => cs.join("\n\n"));

  // Merge field type manifest imports (encoder, decoder, type) into the result
  for (const { manifest } of fieldManifests) {
    result.imports.mergeWith(manifest.encoder.imports);
    result.imports.mergeWith(manifest.decoder.imports);
    result.imports.mergeWith(manifest.type.imports);
  }
  for (const defaultValue of fieldDefaults.values()) {
    result.imports.mergeWith(defaultValue.imports);
  }

  return result;
}

function isOmittedDefaultField(field: StructFieldTypeNode): boolean {
  return field.defaultValue != null && field.defaultValueStrategy === "omitted";
}

function isFieldDiscriminator(
  field: StructFieldTypeNode,
  node: AccountNode,
): boolean {
  return (node.discriminators ?? []).some(
    (discriminator) =>
      discriminator.kind === "fieldDiscriminatorNode" &&
      discriminator.name === field.name,
  );
}
