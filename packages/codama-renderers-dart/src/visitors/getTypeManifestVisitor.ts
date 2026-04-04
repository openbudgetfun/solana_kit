import {
  type AccountNode,
  type AmountTypeNode,
  type ArrayTypeNode,
  type BooleanTypeNode,
  type BytesTypeNode,
  type CamelCaseString,
  type DateTimeTypeNode,
  type DefinedTypeLinkNode,
  type DefinedTypeNode,
  type EnumEmptyVariantTypeNode,
  type EnumStructVariantTypeNode,
  type EnumTupleVariantTypeNode,
  type EnumTypeNode,
  type FixedSizeTypeNode,
  type HiddenPrefixTypeNode,
  type HiddenSuffixTypeNode,
  type InstructionNode,
  type MapTypeNode,
  type NumberTypeNode,
  type OptionTypeNode,
  type PostOffsetTypeNode,
  type PreOffsetTypeNode,
  type PublicKeyTypeNode,
  type RemainderOptionTypeNode,
  type SentinelTypeNode,
  type SetTypeNode,
  type SizePrefixTypeNode,
  type SolAmountTypeNode,
  type StringTypeNode,
  type StructFieldTypeNode,
  type StructTypeNode,
  type TupleTypeNode,
  type ZeroableOptionTypeNode,
  isNode,
  resolveNestedTypeNode,
} from "@codama/nodes";
import {
  type LinkableDictionary,
  type NodeStack,
  type Visitor,
  extendVisitor,
  staticVisitor,
  visit,
} from "@codama/visitors-core";
import { CODAMA_ERROR__UNEXPECTED_NODE_KIND } from "@codama/errors";
import { CodamaError } from "@codama/errors";

import {
  type Fragment,
  type TypeManifest,
  emptyTypeManifest,
  fragment,
  fragmentFromString,
  use,
} from "../utils/index.js";
import { type DartNameApi, snakeCase } from "../utils/nameTransformers.js";

/**
 * Type alias for the type manifest visitor.
 */
export type TypeManifestVisitor = ReturnType<typeof getTypeManifestVisitor>;

/**
 * Creates a visitor that maps Codama type/value nodes to TypeManifest objects.
 * Each TypeManifest contains Dart type, encoder, decoder, and value expressions.
 */
export function getTypeManifestVisitor(input: {
  nameApi: DartNameApi;
  linkables: LinkableDictionary;
  stack: NodeStack;
  nonScalarEnums?: CamelCaseString[];
}) {
  const { nameApi, linkables, nonScalarEnums = [] } = input;

  const baseVisitor = staticVisitor<TypeManifest>(
    (node): TypeManifest => {
      throw new CodamaError(CODAMA_ERROR__UNEXPECTED_NODE_KIND, {
        expectedKinds: ["typeNode"],
        kind: (node as { kind: string }).kind,
      } as never);
    },
    {
      keys: [
        // Type nodes
        "numberTypeNode",
        "booleanTypeNode",
        "stringTypeNode",
        "publicKeyTypeNode",
        "bytesTypeNode",
        "arrayTypeNode",
        "mapTypeNode",
        "setTypeNode",
        "tupleTypeNode",
        "structTypeNode",
        "structFieldTypeNode",
        "enumTypeNode",
        "enumEmptyVariantTypeNode",
        "enumStructVariantTypeNode",
        "enumTupleVariantTypeNode",
        "optionTypeNode",
        "remainderOptionTypeNode",
        "zeroableOptionTypeNode",
        "fixedSizeTypeNode",
        "sizePrefixTypeNode",
        "hiddenPrefixTypeNode",
        "hiddenSuffixTypeNode",
        "sentinelTypeNode",
        "preOffsetTypeNode",
        "postOffsetTypeNode",
        "solAmountTypeNode",
        "amountTypeNode",
        "dateTimeTypeNode",
        "definedTypeLinkNode",
        // Context nodes (for links)
        "definedTypeNode",
        "accountNode",
        "instructionNode",
      ],
    },
  );

  return extendVisitor(baseVisitor, {
    visitNumberType(node: NumberTypeNode, { self }) {
      const { format, endian } = node;
      const endianSuffix =
        endian === "be"
          ? ", NumberCodecConfig(endian: Endian.big)"
          : "";
      const endianDecoderSuffix =
        endian === "be"
          ? ", NumberCodecConfig(endian: Endian.big)"
          : "";

      // Map format to Dart type and codec
      const dartType = getNumberDartType(format);
      const codecName = getNumberCodecName(format);

      return {
        type: dartType === "BigInt"
          ? use("BigInt", "dartTypedData")
          : fragmentFromString(dartType),
        encoder: fragment`${use(
          `get${codecName}Encoder`,
          "solanaCodecsNumbers",
        )}(${endianSuffix ? fragmentFromString(endianSuffix.slice(2)) : fragmentFromString("")})`,
        decoder: fragment`${use(
          `get${codecName}Decoder`,
          "solanaCodecsNumbers",
        )}(${endianDecoderSuffix ? fragmentFromString(endianDecoderSuffix.slice(2)) : fragmentFromString("")})`,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitBooleanType(_node: BooleanTypeNode, { self }) {
      return {
        type: fragmentFromString("bool"),
        encoder: fragment`${use(
          "getBooleanEncoder",
          "solanaCodecsDataStructures",
        )}()`,
        decoder: fragment`${use(
          "getBooleanDecoder",
          "solanaCodecsDataStructures",
        )}()`,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitStringType(node: StringTypeNode, { self }) {
      const { encoding } = node;
      const codecMap: Record<string, string> = {
        utf8: "Utf8",
        base58: "Base58",
        base64: "Base64",
        base16: "Base16",
      };
      const codecName = codecMap[encoding] ?? "Utf8";
      return {
        type: fragmentFromString("String"),
        encoder: fragment`${use(
          `get${codecName}Encoder`,
          "solanaCodecsStrings",
        )}()`,
        decoder: fragment`${use(
          `get${codecName}Decoder`,
          "solanaCodecsStrings",
        )}()`,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitPublicKeyType(_node: PublicKeyTypeNode, { self }) {
      return {
        type: fragment`${use("Address", "solanaAddresses")}`,
        encoder: fragment`${use(
          "getAddressEncoder",
          "solanaAddresses",
        )}()`,
        decoder: fragment`${use(
          "getAddressDecoder",
          "solanaAddresses",
        )}()`,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitBytesType(_node: BytesTypeNode, { self }) {
      return {
        type: fragment`${use("Uint8List", "dartTypedData")}`,
        encoder: fragment`${use(
          "getBytesEncoder",
          "solanaCodecsDataStructures",
        )}()`,
        decoder: fragment`${use(
          "getBytesDecoder",
          "solanaCodecsDataStructures",
        )}()`,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitArrayType(node: ArrayTypeNode, { self }) {
      const itemManifest = visit(node.item, self);
      const sizeExpr = getArraySizeExpression(node);

      return {
        type: fragment`List<${itemManifest.type}>`,
        encoder: fragment`${use(
          "getArrayEncoder",
          "solanaCodecsDataStructures",
        )}(${itemManifest.encoder}${sizeExpr})`,
        decoder: fragment`${use(
          "getArrayDecoder",
          "solanaCodecsDataStructures",
        )}(${itemManifest.decoder}${sizeExpr})`,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitMapType(node: MapTypeNode, { self }) {
      const keyManifest = visit(node.key, self);
      const valueManifest = visit(node.value, self);
      const sizeExpr = getMapSizeExpression(node);

      return {
        type: fragment`Map<${keyManifest.type}, ${valueManifest.type}>`,
        encoder: fragment`${use(
          "getMapEncoder",
          "solanaCodecsDataStructures",
        )}(${keyManifest.encoder}, ${valueManifest.encoder}${sizeExpr})`,
        decoder: fragment`${use(
          "getMapDecoder",
          "solanaCodecsDataStructures",
        )}(${keyManifest.decoder}, ${valueManifest.decoder}${sizeExpr})`,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitSetType(node: SetTypeNode, { self }) {
      const itemManifest = visit(node.item, self);
      const sizeExpr = getSetSizeExpression(node);

      return {
        type: fragment`Set<${itemManifest.type}>`,
        encoder: fragment`${use(
          "getSetEncoder",
          "solanaCodecsDataStructures",
        )}(${itemManifest.encoder}${sizeExpr})`,
        decoder: fragment`${use(
          "getSetDecoder",
          "solanaCodecsDataStructures",
        )}(${itemManifest.decoder}${sizeExpr})`,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitTupleType(node: TupleTypeNode, { self }) {
      const itemManifests = node.items.map((item) => visit(item, self));
      const typeList = itemManifests
        .map((m) => m.type.content)
        .join(", ");
      const encoderList = itemManifests.map((m) => m.encoder);
      const decoderList = itemManifests.map((m) => m.decoder);

      // Merge imports from all items
      const typeFragment = fragment`(${fragmentFromString(typeList)})`;
      for (const m of itemManifests) {
        typeFragment.imports.mergeWith(m.type.imports);
      }

      const encoderListStr = encoderList.map((e) => e.content).join(", ");
      const encoderFrag = fragment`${use(
        "getTupleEncoder",
        "solanaCodecsDataStructures",
      )}([${fragmentFromString(encoderListStr)}])`;
      for (const e of encoderList) {
        encoderFrag.imports.mergeWith(e.imports);
      }

      const decoderListStr = decoderList.map((d) => d.content).join(", ");
      const decoderFrag = fragment`${use(
        "getTupleDecoder",
        "solanaCodecsDataStructures",
      )}([${fragmentFromString(decoderListStr)}])`;
      for (const d of decoderList) {
        decoderFrag.imports.mergeWith(d.imports);
      }

      return {
        type: typeFragment,
        encoder: encoderFrag,
        decoder: decoderFrag,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitStructType(node: StructTypeNode, { self }) {
      const fields = node.fields.map((f) => visit(f, self));
      const fieldNames = node.fields.map((f) => f.name as string);

      // Type: Map<String, Object?> (for inline structs without a name)
      const typeStr = "Map<String, Object?>";

      // Build encoder fields list
      const encoderFields = fields
        .map((f, i) => `('${fieldNames[i]}', ${f.encoder.content})`)
        .join(", ");
      const encoderFrag = fragment`${use(
        "getStructEncoder",
        "solanaCodecsDataStructures",
      )}([${fragmentFromString(encoderFields)}])`;
      for (const f of fields) {
        encoderFrag.imports.mergeWith(f.encoder.imports);
      }

      const decoderFields = fields
        .map((f, i) => `('${fieldNames[i]}', ${f.decoder.content})`)
        .join(", ");
      const decoderFrag = fragment`${use(
        "getStructDecoder",
        "solanaCodecsDataStructures",
      )}([${fragmentFromString(decoderFields)}])`;
      for (const f of fields) {
        decoderFrag.imports.mergeWith(f.decoder.imports);
      }

      return {
        type: fragmentFromString(typeStr),
        encoder: encoderFrag,
        decoder: decoderFrag,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitStructFieldType(node: StructFieldTypeNode, { self }) {
      return visit(node.type, self);
    },

    visitEnumType(node: EnumTypeNode, { self }) {
      // Check if this is a scalar enum (all empty variants)
      const isScalar = node.variants.every(
        (v) => v.kind === "enumEmptyVariantTypeNode",
      );

      if (isScalar) {
        // Scalar enums use a simple int-based encoder
        return {
          type: emptyTypeManifest().type, // Will be replaced by the named type
          encoder: emptyTypeManifest().encoder,
          decoder: emptyTypeManifest().decoder,
          value: emptyTypeManifest().value,
          isEnum: true,
        };
      }

      // Data enum — uses discriminated union
      return {
        type: emptyTypeManifest().type,
        encoder: emptyTypeManifest().encoder,
        decoder: emptyTypeManifest().decoder,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitEnumEmptyVariantType(
      _node: EnumEmptyVariantTypeNode,
      { self },
    ) {
      return emptyTypeManifest();
    },

    visitEnumStructVariantType(
      node: EnumStructVariantTypeNode,
      { self },
    ) {
      return visit(node.struct, self);
    },

    visitEnumTupleVariantType(
      node: EnumTupleVariantTypeNode,
      { self },
    ) {
      return visit(node.tuple, self);
    },

    visitOptionType(node: OptionTypeNode, { self }) {
      const itemManifest = visit(node.item, self);
      const itemTypeStr = itemManifest.type.content;
      const resolvedPrefix = resolveNestedTypeNode(node.prefix);
      const prefixExpr = resolvedPrefix.format !== "u8"
        ? `, prefix: ${getNumberCodecExpression(resolvedPrefix.format, "Encoder")}`
        : "";
      const prefixDecoderExpr = resolvedPrefix.format !== "u8"
        ? `, prefix: ${getNumberCodecExpression(resolvedPrefix.format, "Decoder")}`
        : "";
      const noneValueExpr = node.fixed
        ? ", noneValue: const ZeroesNoneValue()"
        : "";

      return {
        type: fragment`${itemManifest.type}?`,
        encoder: fragment`${use(
          "getNullableEncoder",
          "solanaCodecsDataStructures",
        )}<${fragmentFromString(itemTypeStr)}>(${itemManifest.encoder}${fragmentFromString(prefixExpr)}${fragmentFromString(noneValueExpr)})`,
        decoder: fragment`${use(
          "getNullableDecoder",
          "solanaCodecsDataStructures",
        )}<${fragmentFromString(itemTypeStr)}>(${itemManifest.decoder}${fragmentFromString(prefixDecoderExpr)}${fragmentFromString(noneValueExpr)})`,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitRemainderOptionType(
      node: RemainderOptionTypeNode,
      { self },
    ) {
      const itemManifest = visit(node.item, self);
      const itemTypeStr = itemManifest.type.content;

      return {
        type: fragment`${itemManifest.type}?`,
        encoder: fragment`${use(
          "getNullableEncoder",
          "solanaCodecsDataStructures",
        )}<${fragmentFromString(itemTypeStr)}>(${itemManifest.encoder}, hasPrefix: false)`,
        decoder: fragment`${use(
          "getNullableDecoder",
          "solanaCodecsDataStructures",
        )}<${fragmentFromString(itemTypeStr)}>(${itemManifest.decoder}, hasPrefix: false)`,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitZeroableOptionType(
      node: ZeroableOptionTypeNode,
      { self },
    ) {
      const itemManifest = visit(node.item, self);
      const itemTypeStr = itemManifest.type.content;

      return {
        type: fragment`${itemManifest.type}?`,
        encoder: fragment`${use(
          "getNullableEncoder",
          "solanaCodecsDataStructures",
        )}<${fragmentFromString(itemTypeStr)}>(${itemManifest.encoder}, hasPrefix: false, noneValue: const ZeroesNoneValue())`,
        decoder: fragment`${use(
          "getNullableDecoder",
          "solanaCodecsDataStructures",
        )}<${fragmentFromString(itemTypeStr)}>(${itemManifest.decoder}, hasPrefix: false, noneValue: const ZeroesNoneValue())`,
        value: emptyTypeManifest().value,
        isEnum: false,
      };
    },

    visitFixedSizeType(node: FixedSizeTypeNode, { self }) {
      const innerManifest = visit(node.type, self);

      return {
        type: innerManifest.type,
        encoder: fragment`${use(
          "fixEncoderSize",
          "solanaCodecsCore",
        )}(${innerManifest.encoder}, ${fragmentFromString(String(node.size))})`,
        decoder: fragment`${use(
          "fixDecoderSize",
          "solanaCodecsCore",
        )}(${innerManifest.decoder}, ${fragmentFromString(String(node.size))})`,
        value: innerManifest.value,
        isEnum: innerManifest.isEnum,
      };
    },

    visitSizePrefixType(node: SizePrefixTypeNode, { self }) {
      const innerManifest = visit(node.type, self);
      const prefixManifest = visit(node.prefix, self);

      return {
        type: innerManifest.type,
        encoder: fragment`${use(
          "addEncoderSizePrefix",
          "solanaCodecsCore",
        )}(${innerManifest.encoder}, ${prefixManifest.encoder})`,
        decoder: fragment`${use(
          "addDecoderSizePrefix",
          "solanaCodecsCore",
        )}(${innerManifest.decoder}, ${prefixManifest.decoder})`,
        value: innerManifest.value,
        isEnum: innerManifest.isEnum,
      };
    },

    visitHiddenPrefixType(node: HiddenPrefixTypeNode, { self }) {
      const innerManifest = visit(node.type, self);
      const prefixes = node.prefix.map((p) => getHiddenAffixManifest(p, self));
      const prefixEncoders = prefixes
        .map((p) => p.encoder.content)
        .join(", ");
      const prefixDecoders = prefixes
        .map((p) => p.decoder.content)
        .join(", ");

      const encoderFrag = fragment`${use(
        "getHiddenPrefixEncoder",
        "solanaCodecsDataStructures",
      )}(${innerManifest.encoder}, [${fragmentFromString(prefixEncoders)}])`;
      for (const p of prefixes) {
        encoderFrag.imports.mergeWith(p.encoder.imports);
      }

      const decoderFrag = fragment`${use(
        "getHiddenPrefixDecoder",
        "solanaCodecsDataStructures",
      )}(${innerManifest.decoder}, [${fragmentFromString(prefixDecoders)}])`;
      for (const p of prefixes) {
        decoderFrag.imports.mergeWith(p.decoder.imports);
      }

      return {
        type: innerManifest.type,
        encoder: encoderFrag,
        decoder: decoderFrag,
        value: innerManifest.value,
        isEnum: innerManifest.isEnum,
      };
    },

    visitHiddenSuffixType(node: HiddenSuffixTypeNode, { self }) {
      const innerManifest = visit(node.type, self);
      const suffixes = node.suffix.map((s) => getHiddenAffixManifest(s, self));
      const suffixEncoders = suffixes
        .map((s) => s.encoder.content)
        .join(", ");
      const suffixDecoders = suffixes
        .map((s) => s.decoder.content)
        .join(", ");

      const encoderFrag = fragment`${use(
        "getHiddenSuffixEncoder",
        "solanaCodecsDataStructures",
      )}(${innerManifest.encoder}, [${fragmentFromString(suffixEncoders)}])`;
      for (const s of suffixes) {
        encoderFrag.imports.mergeWith(s.encoder.imports);
      }

      const decoderFrag = fragment`${use(
        "getHiddenSuffixDecoder",
        "solanaCodecsDataStructures",
      )}(${innerManifest.decoder}, [${fragmentFromString(suffixDecoders)}])`;
      for (const s of suffixes) {
        decoderFrag.imports.mergeWith(s.decoder.imports);
      }

      return {
        type: innerManifest.type,
        encoder: encoderFrag,
        decoder: decoderFrag,
        value: innerManifest.value,
        isEnum: innerManifest.isEnum,
      };
    },

    visitSentinelType(node: SentinelTypeNode, { self }) {
      const innerManifest = visit(node.type, self);
      const sentinelManifest = visit(node.sentinel, self);

      return {
        type: innerManifest.type,
        encoder: fragment`${use(
          "addEncoderSentinel",
          "solanaCodecsCore",
        )}(${innerManifest.encoder}, ${sentinelManifest.encoder})`,
        decoder: fragment`${use(
          "addDecoderSentinel",
          "solanaCodecsCore",
        )}(${innerManifest.decoder}, ${sentinelManifest.decoder})`,
        value: innerManifest.value,
        isEnum: innerManifest.isEnum,
      };
    },

    visitPreOffsetType(node: PreOffsetTypeNode, { self }) {
      // Pre-offset types pass through to inner type in Dart
      return visit(node.type, self);
    },

    visitPostOffsetType(node: PostOffsetTypeNode, { self }) {
      // Post-offset types pass through to inner type in Dart
      return visit(node.type, self);
    },

    visitSolAmountType(node: SolAmountTypeNode, { self }) {
      // SolAmount maps to BigInt (lamports)
      return visit(node.number, self);
    },

    visitAmountType(node: AmountTypeNode, { self }) {
      // Amount types pass through to their number type
      return visit(node.number, self);
    },

    visitDateTimeType(node: DateTimeTypeNode, { self }) {
      // DateTime types pass through to their number type
      return visit(node.number, self);
    },

    visitDefinedTypeLink(
      node: DefinedTypeLinkNode,
      { self }: { self: Visitor<TypeManifest> },
    ) {
      const name = node.name as string;
      const typeName = nameApi.dataType(name);
      const isNonScalar = nonScalarEnums.includes(node.name);
      const moduleKey = `definedType:${snakeCase(name)}`;

      return {
        type: fragment`${use(typeName, moduleKey)}`,
        encoder: fragment`${use(nameApi.encoderFunction(name), moduleKey)}()`,
        decoder: fragment`${use(nameApi.decoderFunction(name), moduleKey)}()`,
        value: emptyTypeManifest().value,
        isEnum: !isNonScalar,
      };
    },

    visitDefinedType(node: DefinedTypeNode, { self }) {
      return visit(node.type, self);
    },

    visitAccount(node: AccountNode, { self }) {
      return visit(node.data, self);
    },

    visitInstruction(node: InstructionNode, { self }) {
      return emptyTypeManifest();
    },
  });
}

// --- Helper functions ---

function getNumberDartType(
  format: string,
): string {
  switch (format) {
    case "u8":
    case "u16":
    case "u32":
    case "i8":
    case "i16":
    case "i32":
    case "shortU16":
      return "int";
    case "u64":
    case "u128":
    case "i64":
    case "i128":
      return "BigInt";
    case "f32":
    case "f64":
      return "double";
    default:
      return "int";
  }
}

function getNumberCodecName(format: string): string {
  switch (format) {
    case "u8":
      return "U8";
    case "u16":
      return "U16";
    case "u32":
      return "U32";
    case "u64":
      return "U64";
    case "u128":
      return "U128";
    case "i8":
      return "I8";
    case "i16":
      return "I16";
    case "i32":
      return "I32";
    case "i64":
      return "I64";
    case "i128":
      return "I128";
    case "f32":
      return "F32";
    case "f64":
      return "F64";
    case "shortU16":
      return "ShortU16";
    default:
      return "U8";
  }
}

function getNumberCodecExpression(
  format: string,
  codecType: "Encoder" | "Decoder",
): string {
  const name = getNumberCodecName(format);
  return `get${name}${codecType}()`;
}

function getArraySizeExpression(node: ArrayTypeNode): string {
  if (!("count" in node) || !node.count) return "";
  const count = node.count;
  switch (count.kind) {
    case "fixedCountNode":
      return `, size: FixedArraySize(${count.value})`;
    case "remainderCountNode":
      return ", size: RemainderArraySize()";
    case "prefixedCountNode": {
      const resolvedPrefix = resolveNestedTypeNode(count.prefix);
      if (resolvedPrefix.format === "u32" && (!resolvedPrefix.endian || resolvedPrefix.endian === "le")) {
        return ""; // Default
      }
      return `, size: PrefixedArraySize(get${getNumberCodecName(resolvedPrefix.format)}Encoder())`;
    }
    default:
      return "";
  }
}

function getMapSizeExpression(node: MapTypeNode): string {
  if (!("count" in node) || !node.count) return "";
  const count = node.count;
  switch (count.kind) {
    case "fixedCountNode":
      return `, size: FixedArraySize(${count.value})`;
    case "remainderCountNode":
      return ", size: RemainderArraySize()";
    case "prefixedCountNode": {
      const resolvedPrefix = resolveNestedTypeNode(count.prefix);
      if (resolvedPrefix.format === "u32" && (!resolvedPrefix.endian || resolvedPrefix.endian === "le")) {
        return "";
      }
      return `, size: PrefixedArraySize(get${getNumberCodecName(resolvedPrefix.format)}Encoder())`;
    }
    default:
      return "";
  }
}

function getSetSizeExpression(node: SetTypeNode): string {
  if (!("count" in node) || !node.count) return "";
  const count = node.count;
  switch (count.kind) {
    case "fixedCountNode":
      return `, size: FixedArraySize(${count.value})`;
    case "remainderCountNode":
      return ", size: RemainderArraySize()";
    case "prefixedCountNode": {
      const resolvedPrefix = resolveNestedTypeNode(count.prefix);
      if (resolvedPrefix.format === "u32" && (!resolvedPrefix.endian || resolvedPrefix.endian === "le")) {
        return "";
      }
      return `, size: PrefixedArraySize(get${getNumberCodecName(resolvedPrefix.format)}Encoder())`;
    }
    default:
      return "";
  }
}

type HiddenAffixManifest = {
  encoder: Fragment;
  decoder: Fragment;
};

function getHiddenAffixManifest(
  node: any,
  self: Visitor<TypeManifest>,
): HiddenAffixManifest {
  if (node?.kind !== "constantValueNode") {
    const manifest = visit(node, self);
    return { encoder: manifest.encoder, decoder: manifest.decoder };
  }

  const constantBytes = getConstantBytesExpression(node);
  return {
    encoder: fragment`${use("getConstantEncoder", "solanaCodecsDataStructures")}(${constantBytes})`,
    decoder: fragment`${use("getConstantDecoder", "solanaCodecsDataStructures")}(${constantBytes})`,
  };
}

function getConstantBytesExpression(node: any): Fragment {
  const valueNode = node.value;
  const typeNode = node.type;

  if (valueNode?.kind !== "numberValueNode") {
    throw new Error(
      `Unsupported hidden affix constant value kind: ${valueNode?.kind}`,
    );
  }

  const value = Number(valueNode.number);

  if (typeNode?.kind === "numberTypeNode") {
    return fragment`${use(`get${getNumberCodecName(typeNode.format)}Encoder`, "solanaCodecsNumbers")}().encode(${value})`;
  }

  if (typeNode?.kind === "preOffsetTypeNode") {
    const inner = typeNode.type;
    if (inner?.kind !== "numberTypeNode") {
      throw new Error(
        `Unsupported hidden affix pre-offset inner type kind: ${inner?.kind}`,
      );
    }
    return fragment`${use("padLeftEncoder", "solanaCodecsCore")}(${use(`get${getNumberCodecName(inner.format)}Encoder`, "solanaCodecsNumbers")}(), ${typeNode.offset}).encode(${value})`;
  }

  throw new Error(
    `Unsupported hidden affix constant type kind: ${typeNode?.kind}`,
  );
}
