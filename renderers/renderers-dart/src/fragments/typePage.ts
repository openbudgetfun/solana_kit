import type { DefinedTypeNode, StructFieldTypeNode, TypeNode } from "@codama/nodes";
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
import {
  camelCase,
  pascalCase,
  snakeCase,
} from "../utils/nameTransformers.js";

/**
 * Generate a full Dart file for a defined type.
 */
export function getTypePageFragment(
  node: DefinedTypeNode,
  scope: RenderScope,
): Fragment {
  const name = node.name as string;
  const typeName = scope.nameApi.dataType(name);
  const typeNode = node.type;

  // Check what kind of type this is
  if (typeNode.kind === "enumTypeNode") {
    const isScalar = typeNode.variants.every(
      (v) => v.kind === "enumEmptyVariantTypeNode",
    );
    if (isScalar) {
      return getScalarEnumPageFragment(node, scope);
    }
    return getDataEnumPageFragment(node, scope);
  }

  if (typeNode.kind === "structTypeNode") {
    return getStructPageFragment(node, scope);
  }

  // Simple type alias — just create codec wrappers
  return getTypeAliasPageFragment(node, scope);
}

/**
 * Generate a Dart scalar enum (all empty variants).
 */
function getScalarEnumPageFragment(
  node: DefinedTypeNode,
  scope: RenderScope,
): Fragment {
  const name = node.name as string;
  const typeName = scope.nameApi.dataType(name);
  const enumNode = node.type;
  if (enumNode.kind !== "enumTypeNode") return emptyFragment();

  const variants = enumNode.variants.map((v) => {
    const variantName = scope.nameApi.enumVariant(v.name as string);
    return variantName;
  });

  const variantLines = variants.map((v: string) => `  ${v},`).join("\n");
  const encoderName = scope.nameApi.encoderFunction(name);
  const decoderName = scope.nameApi.decoderFunction(name);
  const codecName = scope.nameApi.codecFunction(name);

  // Determine size codec from the enum node's size if available
  const resolvedSize = resolveNestedTypeNode(enumNode.size);
  const sizeType = resolvedSize.format ?? "u8";
  const sizeCodecName = getNumberCodecName(sizeType);

  return fragment`// Auto-generated. Do not edit.
// ignore_for_file: type=lint

${use("Uint8List", "dartTypedData")}
${use("Encoder", "solanaCodecsCore")}
${use("Decoder", "solanaCodecsCore")}
${use("Codec", "solanaCodecsCore")}
${use("combineCodec", "solanaCodecsCore")}
${use("transformEncoder", "solanaCodecsCore")}
${use("transformDecoder", "solanaCodecsCore")}
${use("get${sizeCodecName}Encoder", "solanaCodecsNumbers")}
${use("get${sizeCodecName}Decoder", "solanaCodecsNumbers")}

enum ${fragmentFromString(typeName)} {
${fragmentFromString(variantLines)}
}

Encoder<${fragmentFromString(typeName)}> ${fragmentFromString(encoderName)}() {
  return transformEncoder(
    get${fragmentFromString(sizeCodecName)}Encoder(),
    (${fragmentFromString(typeName)} value) => value.index,
  );
}

Decoder<${fragmentFromString(typeName)}> ${fragmentFromString(decoderName)}() {
  return transformDecoder(
    get${fragmentFromString(sizeCodecName)}Decoder(),
    (num value) => ${fragmentFromString(typeName)}.values[value.toInt()],
  );
}

Codec<${fragmentFromString(typeName)}, ${fragmentFromString(typeName)}> ${fragmentFromString(codecName)}() {
  return combineCodec(${fragmentFromString(encoderName)}(), ${fragmentFromString(decoderName)}());
}`;
}

/**
 * Generate a Dart data enum (sealed class with variants).
 */
function getDataEnumPageFragment(
  node: DefinedTypeNode,
  scope: RenderScope,
): Fragment {
  const name = node.name as string;
  const typeName = scope.nameApi.dataType(name);
  const enumNode = node.type;
  if (enumNode.kind !== "enumTypeNode") return emptyFragment();

  const variantClasses: string[] = [];
  const encoderVariants: string[] = [];
  const decoderVariants: string[] = [];

  for (let i = 0; i < enumNode.variants.length; i++) {
    const variant = enumNode.variants[i];
    const variantClassName = scope.nameApi.sealedClassVariant(
      name,
      variant.name as string,
    );

    if (variant.kind === "enumEmptyVariantTypeNode") {
      variantClasses.push(`final class ${variantClassName} extends ${typeName} {
  const ${variantClassName}();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ${variantClassName};

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => '${typeName}.${variantClassName}()';
}`);

      encoderVariants.push(
        `(${i}, getStructEncoder(<(String, Encoder<Object?>)>[]))`,
      );
      decoderVariants.push(
        `(${i}, getStructDecoder(<(String, Decoder<Object?>)>[]).map((_) => const ${variantClassName}()))`,
      );
    } else if (variant.kind === "enumStructVariantTypeNode") {
      const resolvedStruct = resolveNestedTypeNode(variant.struct);
      const fields = resolvedStruct.fields;
      const fieldDecls = fields
        .map((f: StructFieldTypeNode) => {
          const manifest = visit(f.type, scope.typeManifestVisitor);
          return `  final ${manifest.type.content} ${camelCase(f.name as string)};`;
        })
        .join("\n");

      const ctorParams = fields
        .map((f: StructFieldTypeNode) => `    required this.${camelCase(f.name as string)},`)
        .join("\n");

      const eqChecks = fields
        .map((f: StructFieldTypeNode) => `${camelCase(f.name as string)} == other.${camelCase(f.name as string)}`)
        .join(" &&\n          ");

      const hashFields = fields
        .map((f: StructFieldTypeNode) => camelCase(f.name as string))
        .join(", ");

      const toStringFields = fields
        .map((f: StructFieldTypeNode) => `${camelCase(f.name as string)}: $${camelCase(f.name as string)}`)
        .join(", ");

      variantClasses.push(`final class ${variantClassName} extends ${typeName} {
  const ${variantClassName}({
${ctorParams}
  });

${fieldDecls}

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ${variantClassName} &&
          ${eqChecks};

  @override
  int get hashCode => Object.hash(${hashFields});

  @override
  String toString() => '${typeName}.${variantClassName}(${toStringFields})';
}`);

      const encFields = fields
        .map((f: StructFieldTypeNode) => {
          const manifest = visit(f.type, scope.typeManifestVisitor);
          return `('${f.name as string}', ${manifest.encoder.content})`;
        })
        .join(", ");

      const decFields = fields
        .map((f: StructFieldTypeNode) => {
          const manifest = visit(f.type, scope.typeManifestVisitor);
          return `('${f.name as string}', ${manifest.decoder.content})`;
        })
        .join(", ");

      const fromMapFields = fields
        .map(
          (f: StructFieldTypeNode) =>
            `${camelCase(f.name as string)}: map['${f.name as string}']! as ${visit(f.type, scope.typeManifestVisitor).type.content}`,
        )
        .join(", ");

      const toMapFields = fields
        .map(
          (f: StructFieldTypeNode) =>
            `'${f.name as string}': value.${camelCase(f.name as string)}`,
        )
        .join(", ");

      encoderVariants.push(
        `(${i}, transformEncoder(getStructEncoder([${encFields}]), (${variantClassName} value) => <String, Object?>{${toMapFields}}))`,
      );
      decoderVariants.push(
        `(${i}, transformDecoder(getStructDecoder([${decFields}]), (Map<String, Object?> map) => ${variantClassName}(${fromMapFields})))`,
      );
    } else if (variant.kind === "enumTupleVariantTypeNode") {
      const resolvedTuple = resolveNestedTypeNode(variant.tuple);
      const items = resolvedTuple.items;
      if (items.length === 1) {
        const manifest = visit(items[0], scope.typeManifestVisitor);
        variantClasses.push(`final class ${variantClassName} extends ${typeName} {
  const ${variantClassName}(this.value);

  final ${manifest.type.content} value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ${variantClassName} && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '${typeName}.${variantClassName}(\$value)';
}`);
        encoderVariants.push(
          `(${i}, transformEncoder(${manifest.encoder.content}, (${variantClassName} value) => value.value))`,
        );
        decoderVariants.push(
          `(${i}, transformDecoder(${manifest.decoder.content}, (${manifest.type.content} value) => ${variantClassName}(value)))`,
        );
      }
    }
  }

  const encoderName = scope.nameApi.encoderFunction(name);
  const decoderName = scope.nameApi.decoderFunction(name);
  const codecName = scope.nameApi.codecFunction(name);
  const resolvedSize = resolveNestedTypeNode(enumNode.size);
  const sizeType = resolvedSize.format ?? "u8";
  const sizeCodecName = getNumberCodecName(sizeType);

  const result = fragment`// Auto-generated. Do not edit.
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
${use("getDiscriminatedUnionEncoder", "solanaCodecsDataStructures")}
${use("getDiscriminatedUnionDecoder", "solanaCodecsDataStructures")}
${use("get${sizeCodecName}Encoder", "solanaCodecsNumbers")}
${use("get${sizeCodecName}Decoder", "solanaCodecsNumbers")}

sealed class ${fragmentFromString(typeName)} {
  const ${fragmentFromString(typeName)}();
}

${fragmentFromString(variantClasses.join("\n\n"))}

Encoder<${fragmentFromString(typeName)}> ${fragmentFromString(encoderName)}() {
  return getDiscriminatedUnionEncoder([
    ${fragmentFromString(encoderVariants.join(",\n    "))},
  ], size: get${fragmentFromString(sizeCodecName)}Encoder());
}

Decoder<${fragmentFromString(typeName)}> ${fragmentFromString(decoderName)}() {
  return getDiscriminatedUnionDecoder([
    ${fragmentFromString(decoderVariants.join(",\n    "))},
  ], size: get${fragmentFromString(sizeCodecName)}Decoder());
}

Codec<${fragmentFromString(typeName)}, ${fragmentFromString(typeName)}> ${fragmentFromString(codecName)}() {
  return combineCodec(${fragmentFromString(encoderName)}(), ${fragmentFromString(decoderName)}());
}`;

  return result;
}

/**
 * Generate a Dart @immutable class for a struct type.
 */
function getStructPageFragment(
  node: DefinedTypeNode,
  scope: RenderScope,
): Fragment {
  const name = node.name as string;
  const typeName = scope.nameApi.dataType(name);
  const structNode = node.type;
  if (structNode.kind !== "structTypeNode") return emptyFragment();

  const fields = structNode.fields;

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

  const encoderName = scope.nameApi.encoderFunction(name);
  const decoderName = scope.nameApi.decoderFunction(name);
  const codecName = scope.nameApi.codecFunction(name);

  // Build encoder/decoder field lists
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

  const result = fragment`// Auto-generated. Do not edit.
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
}

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
}`;

  return result;
}

/**
 * Generate a simple type alias with codec wrappers.
 */
function getTypeAliasPageFragment(
  node: DefinedTypeNode,
  scope: RenderScope,
): Fragment {
  const name = node.name as string;
  const typeName = scope.nameApi.dataType(name);
  const manifest = visit(node.type, scope.typeManifestVisitor);

  const encoderName = scope.nameApi.encoderFunction(name);
  const decoderName = scope.nameApi.decoderFunction(name);
  const codecName = scope.nameApi.codecFunction(name);

  return fragment`// Auto-generated. Do not edit.
// ignore_for_file: type=lint

${use("Encoder", "solanaCodecsCore")}
${use("Decoder", "solanaCodecsCore")}
${use("Codec", "solanaCodecsCore")}
${use("combineCodec", "solanaCodecsCore")}

typedef ${fragmentFromString(typeName)} = ${manifest.type};

Encoder<${fragmentFromString(typeName)}> ${fragmentFromString(encoderName)}() {
  return ${manifest.encoder};
}

Decoder<${fragmentFromString(typeName)}> ${fragmentFromString(decoderName)}() {
  return ${manifest.decoder};
}

Codec<${fragmentFromString(typeName)}, ${fragmentFromString(typeName)}> ${fragmentFromString(codecName)}() {
  return combineCodec(${fragmentFromString(encoderName)}(), ${fragmentFromString(decoderName)}());
}`;
}

function getNumberCodecName(format: string): string {
  switch (format) {
    case "u8": return "U8";
    case "u16": return "U16";
    case "u32": return "U32";
    case "u64": return "U64";
    case "u128": return "U128";
    case "i8": return "I8";
    case "i16": return "I16";
    case "i32": return "I32";
    case "i64": return "I64";
    case "i128": return "I128";
    case "f32": return "F32";
    case "f64": return "F64";
    case "shortU16": return "ShortU16";
    default: return "U8";
  }
}
