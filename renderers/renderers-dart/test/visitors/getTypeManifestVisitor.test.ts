import {
  arrayTypeNode,
  booleanTypeNode,
  bytesTypeNode,
  definedTypeLinkNode,
  enumEmptyVariantTypeNode,
  enumStructVariantTypeNode,
  enumTupleVariantTypeNode,
  enumTypeNode,
  fixedCountNode,
  fixedSizeTypeNode,
  mapTypeNode,
  numberTypeNode,
  optionTypeNode,
  prefixedCountNode,
  publicKeyTypeNode,
  remainderCountNode,
  setTypeNode,
  stringTypeNode,
  structFieldTypeNode,
  structTypeNode,
  tupleTypeNode,
} from "@codama/nodes";
import {
  LinkableDictionary,
  NodeStack,
  visit,
} from "@codama/visitors-core";
import { describe, expect, it } from "vitest";

import { createDartNameApi } from "../../src/utils/nameTransformers.js";
import { getTypeManifestVisitor } from "../../src/visitors/getTypeManifestVisitor.js";

function createVisitor() {
  return getTypeManifestVisitor({
    nameApi: createDartNameApi(),
    linkables: new LinkableDictionary(),
    stack: new NodeStack(),
  });
}

describe("getTypeManifestVisitor", () => {
  describe("numberTypeNode", () => {
    it("maps u8 to int and getU8Encoder/Decoder", () => {
      const manifest = visit(numberTypeNode("u8"), createVisitor());
      expect(manifest.type.content).toBe("int");
      expect(manifest.encoder.content).toContain("getU8Encoder");
      expect(manifest.decoder.content).toContain("getU8Decoder");
      expect(manifest.isEnum).toBe(false);
    });

    it("maps u16 to int and getU16Encoder/Decoder", () => {
      const manifest = visit(numberTypeNode("u16"), createVisitor());
      expect(manifest.type.content).toBe("int");
      expect(manifest.encoder.content).toContain("getU16Encoder");
      expect(manifest.decoder.content).toContain("getU16Decoder");
    });

    it("maps u32 to int and getU32Encoder/Decoder", () => {
      const manifest = visit(numberTypeNode("u32"), createVisitor());
      expect(manifest.type.content).toBe("int");
      expect(manifest.encoder.content).toContain("getU32Encoder");
      expect(manifest.decoder.content).toContain("getU32Decoder");
    });

    it("maps u64 to BigInt and getU64Encoder/Decoder", () => {
      const manifest = visit(numberTypeNode("u64"), createVisitor());
      expect(manifest.type.content).toBe("BigInt");
      expect(manifest.encoder.content).toContain("getU64Encoder");
      expect(manifest.decoder.content).toContain("getU64Decoder");
    });

    it("maps u128 to BigInt and getU128Encoder/Decoder", () => {
      const manifest = visit(numberTypeNode("u128"), createVisitor());
      expect(manifest.type.content).toBe("BigInt");
      expect(manifest.encoder.content).toContain("getU128Encoder");
      expect(manifest.decoder.content).toContain("getU128Decoder");
    });

    it("maps i8 to int", () => {
      const manifest = visit(numberTypeNode("i8"), createVisitor());
      expect(manifest.type.content).toBe("int");
      expect(manifest.encoder.content).toContain("getI8Encoder");
    });

    it("maps i16 to int", () => {
      const manifest = visit(numberTypeNode("i16"), createVisitor());
      expect(manifest.type.content).toBe("int");
      expect(manifest.encoder.content).toContain("getI16Encoder");
    });

    it("maps i32 to int", () => {
      const manifest = visit(numberTypeNode("i32"), createVisitor());
      expect(manifest.type.content).toBe("int");
      expect(manifest.encoder.content).toContain("getI32Encoder");
    });

    it("maps i64 to BigInt", () => {
      const manifest = visit(numberTypeNode("i64"), createVisitor());
      expect(manifest.type.content).toBe("BigInt");
      expect(manifest.encoder.content).toContain("getI64Encoder");
    });

    it("maps i128 to BigInt", () => {
      const manifest = visit(numberTypeNode("i128"), createVisitor());
      expect(manifest.type.content).toBe("BigInt");
      expect(manifest.encoder.content).toContain("getI128Encoder");
    });

    it("maps f32 to double", () => {
      const manifest = visit(numberTypeNode("f32"), createVisitor());
      expect(manifest.type.content).toBe("double");
      expect(manifest.encoder.content).toContain("getF32Encoder");
    });

    it("maps f64 to double", () => {
      const manifest = visit(numberTypeNode("f64"), createVisitor());
      expect(manifest.type.content).toBe("double");
      expect(manifest.encoder.content).toContain("getF64Encoder");
    });

    it("maps shortU16 to int", () => {
      const manifest = visit(numberTypeNode("shortU16"), createVisitor());
      expect(manifest.type.content).toBe("int");
      expect(manifest.encoder.content).toContain("getShortU16Encoder");
      expect(manifest.decoder.content).toContain("getShortU16Decoder");
    });

    it("adds big-endian config for be numbers", () => {
      const manifest = visit(numberTypeNode("u32", "be"), createVisitor());
      expect(manifest.encoder.content).toContain("Endian.big");
      expect(manifest.decoder.content).toContain("Endian.big");
    });

    it("does not add endian config for le numbers", () => {
      const manifest = visit(numberTypeNode("u32", "le"), createVisitor());
      expect(manifest.encoder.content).not.toContain("Endian.big");
    });

    it("adds solanaCodecsNumbers import", () => {
      const manifest = visit(numberTypeNode("u8"), createVisitor());
      expect(
        manifest.encoder.imports.modules.has("solanaCodecsNumbers"),
      ).toBe(true);
      expect(
        manifest.decoder.imports.modules.has("solanaCodecsNumbers"),
      ).toBe(true);
    });
  });

  describe("booleanTypeNode", () => {
    it("maps to bool type", () => {
      const manifest = visit(booleanTypeNode(), createVisitor());
      expect(manifest.type.content).toBe("bool");
    });

    it("uses getBooleanEncoder/Decoder", () => {
      const manifest = visit(booleanTypeNode(), createVisitor());
      expect(manifest.encoder.content).toContain("getBooleanEncoder");
      expect(manifest.decoder.content).toContain("getBooleanDecoder");
    });

    it("adds solanaCodecsDataStructures import", () => {
      const manifest = visit(booleanTypeNode(), createVisitor());
      expect(
        manifest.encoder.imports.modules.has("solanaCodecsDataStructures"),
      ).toBe(true);
    });
  });

  describe("stringTypeNode", () => {
    it("maps utf8 encoding", () => {
      const manifest = visit(stringTypeNode("utf8"), createVisitor());
      expect(manifest.type.content).toBe("String");
      expect(manifest.encoder.content).toContain("getUtf8Encoder");
      expect(manifest.decoder.content).toContain("getUtf8Decoder");
    });

    it("maps base58 encoding", () => {
      const manifest = visit(stringTypeNode("base58"), createVisitor());
      expect(manifest.encoder.content).toContain("getBase58Encoder");
      expect(manifest.decoder.content).toContain("getBase58Decoder");
    });

    it("maps base64 encoding", () => {
      const manifest = visit(stringTypeNode("base64"), createVisitor());
      expect(manifest.encoder.content).toContain("getBase64Encoder");
      expect(manifest.decoder.content).toContain("getBase64Decoder");
    });

    it("maps base16 encoding", () => {
      const manifest = visit(stringTypeNode("base16"), createVisitor());
      expect(manifest.encoder.content).toContain("getBase16Encoder");
      expect(manifest.decoder.content).toContain("getBase16Decoder");
    });

    it("adds solanaCodecsStrings import", () => {
      const manifest = visit(stringTypeNode("utf8"), createVisitor());
      expect(
        manifest.encoder.imports.modules.has("solanaCodecsStrings"),
      ).toBe(true);
    });
  });

  describe("publicKeyTypeNode", () => {
    it("maps to Address type", () => {
      const manifest = visit(publicKeyTypeNode(), createVisitor());
      expect(manifest.type.content).toBe("Address");
    });

    it("uses getAddressEncoder/Decoder", () => {
      const manifest = visit(publicKeyTypeNode(), createVisitor());
      expect(manifest.encoder.content).toContain("getAddressEncoder");
      expect(manifest.decoder.content).toContain("getAddressDecoder");
    });

    it("adds solanaAddresses import", () => {
      const manifest = visit(publicKeyTypeNode(), createVisitor());
      expect(manifest.type.imports.modules.has("solanaAddresses")).toBe(true);
      expect(manifest.encoder.imports.modules.has("solanaAddresses")).toBe(
        true,
      );
    });
  });

  describe("bytesTypeNode", () => {
    it("maps to Uint8List type", () => {
      const manifest = visit(bytesTypeNode(), createVisitor());
      expect(manifest.type.content).toBe("Uint8List");
    });

    it("uses getBytesEncoder/Decoder", () => {
      const manifest = visit(bytesTypeNode(), createVisitor());
      expect(manifest.encoder.content).toContain("getBytesEncoder");
      expect(manifest.decoder.content).toContain("getBytesDecoder");
    });

    it("adds dartTypedData import for Uint8List", () => {
      const manifest = visit(bytesTypeNode(), createVisitor());
      expect(manifest.type.imports.modules.has("dartTypedData")).toBe(true);
    });
  });

  describe("arrayTypeNode", () => {
    it("maps to List<T> type", () => {
      const node = arrayTypeNode(
        numberTypeNode("u8"),
        prefixedCountNode(numberTypeNode("u32")),
      );
      const manifest = visit(node, createVisitor());
      expect(manifest.type.content).toBe("List<int>");
    });

    it("uses getArrayEncoder/Decoder for prefixed count", () => {
      const node = arrayTypeNode(
        numberTypeNode("u8"),
        prefixedCountNode(numberTypeNode("u32")),
      );
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toContain("getArrayEncoder");
      expect(manifest.decoder.content).toContain("getArrayDecoder");
    });

    it("includes FixedArraySize for fixed count", () => {
      const node = arrayTypeNode(numberTypeNode("u8"), fixedCountNode(5));
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toContain("FixedArraySize(5)");
    });

    it("includes RemainderArraySize for remainder count", () => {
      const node = arrayTypeNode(
        numberTypeNode("u8"),
        remainderCountNode(),
      );
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toContain("RemainderArraySize()");
    });

    it("omits size param for default u32 prefixed count", () => {
      const node = arrayTypeNode(
        numberTypeNode("u8"),
        prefixedCountNode(numberTypeNode("u32")),
      );
      const manifest = visit(node, createVisitor());
      // Should not have a size: parameter since u32 is default
      expect(manifest.encoder.content).not.toContain("size:");
    });

    it("includes PrefixedArraySize for non-default prefixed count", () => {
      const node = arrayTypeNode(
        numberTypeNode("u8"),
        prefixedCountNode(numberTypeNode("u16")),
      );
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toContain("PrefixedArraySize");
      expect(manifest.encoder.content).toContain("getU16Encoder");
    });

    it("handles nested array types", () => {
      const inner = arrayTypeNode(
        numberTypeNode("u8"),
        prefixedCountNode(numberTypeNode("u32")),
      );
      const outer = arrayTypeNode(
        inner,
        prefixedCountNode(numberTypeNode("u32")),
      );
      const manifest = visit(outer, createVisitor());
      expect(manifest.type.content).toBe("List<List<int>>");
    });
  });

  describe("optionTypeNode", () => {
    it("maps to nullable type T?", () => {
      const node = optionTypeNode(numberTypeNode("u8"));
      const manifest = visit(node, createVisitor());
      expect(manifest.type.content).toBe("int?");
    });

    it("uses getNullableEncoder/Decoder", () => {
      const node = optionTypeNode(numberTypeNode("u8"));
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toContain("getNullableEncoder");
      expect(manifest.decoder.content).toContain("getNullableDecoder");
    });

    it("does not include prefix param for default u8", () => {
      const node = optionTypeNode(numberTypeNode("u8"));
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).not.toContain("prefix:");
    });

    it("includes prefix param for non-default prefix", () => {
      const node = optionTypeNode(numberTypeNode("u8"), {
        prefix: numberTypeNode("u32"),
      });
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toContain("prefix:");
    });

    it("handles option of publicKeyTypeNode", () => {
      const node = optionTypeNode(publicKeyTypeNode());
      const manifest = visit(node, createVisitor());
      expect(manifest.type.content).toBe("Address?");
    });
  });

  describe("structTypeNode", () => {
    it("maps inline struct to Map<String, Object?>", () => {
      const node = structTypeNode([
        structFieldTypeNode({ name: "amount", type: numberTypeNode("u64") }),
        structFieldTypeNode({
          name: "owner",
          type: publicKeyTypeNode(),
        }),
      ]);
      const manifest = visit(node, createVisitor());
      expect(manifest.type.content).toBe("Map<String, Object?>");
    });

    it("uses getStructEncoder/Decoder", () => {
      const node = structTypeNode([
        structFieldTypeNode({ name: "amount", type: numberTypeNode("u64") }),
      ]);
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toContain("getStructEncoder");
      expect(manifest.decoder.content).toContain("getStructDecoder");
    });

    it("includes field names in encoder", () => {
      const node = structTypeNode([
        structFieldTypeNode({ name: "amount", type: numberTypeNode("u64") }),
        structFieldTypeNode({ name: "name", type: stringTypeNode("utf8") }),
      ]);
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toContain("'amount'");
      expect(manifest.encoder.content).toContain("'name'");
    });

    it("handles empty struct", () => {
      const node = structTypeNode([]);
      const manifest = visit(node, createVisitor());
      expect(manifest.type.content).toBe("Map<String, Object?>");
      expect(manifest.encoder.content).toContain("getStructEncoder");
    });
  });

  describe("enumTypeNode", () => {
    it("marks scalar enums with isEnum = true", () => {
      const node = enumTypeNode([
        enumEmptyVariantTypeNode("first"),
        enumEmptyVariantTypeNode("second"),
      ]);
      const manifest = visit(node, createVisitor());
      expect(manifest.isEnum).toBe(true);
    });

    it("marks data enums with isEnum = false", () => {
      const node = enumTypeNode([
        enumEmptyVariantTypeNode("first"),
        enumStructVariantTypeNode(
          "second",
          structTypeNode([
            structFieldTypeNode({
              name: "value",
              type: numberTypeNode("u32"),
            }),
          ]),
        ),
      ]);
      const manifest = visit(node, createVisitor());
      expect(manifest.isEnum).toBe(false);
    });
  });

  describe("fixedSizeTypeNode", () => {
    it("wraps encoder with fixEncoderSize", () => {
      const node = fixedSizeTypeNode(stringTypeNode("utf8"), 32);
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toContain("fixEncoderSize");
      expect(manifest.encoder.content).toContain("32");
    });

    it("wraps decoder with fixDecoderSize", () => {
      const node = fixedSizeTypeNode(stringTypeNode("utf8"), 32);
      const manifest = visit(node, createVisitor());
      expect(manifest.decoder.content).toContain("fixDecoderSize");
      expect(manifest.decoder.content).toContain("32");
    });

    it("preserves the inner type", () => {
      const node = fixedSizeTypeNode(stringTypeNode("utf8"), 32);
      const manifest = visit(node, createVisitor());
      expect(manifest.type.content).toBe("String");
    });

    it("adds solanaCodecsCore import", () => {
      const node = fixedSizeTypeNode(stringTypeNode("utf8"), 32);
      const manifest = visit(node, createVisitor());
      expect(
        manifest.encoder.imports.modules.has("solanaCodecsCore"),
      ).toBe(true);
    });

    it("handles fixed-size bytes", () => {
      const node = fixedSizeTypeNode(bytesTypeNode(), 64);
      const manifest = visit(node, createVisitor());
      expect(manifest.type.content).toBe("Uint8List");
      expect(manifest.encoder.content).toContain("fixEncoderSize");
      expect(manifest.encoder.content).toContain("64");
    });
  });

  describe("definedTypeLinkNode", () => {
    it("uses the name API for type name", () => {
      const node = definedTypeLinkNode("myCustomType");
      const manifest = visit(node, createVisitor());
      expect(manifest.type.content).toBe("MyCustomType");
    });

    it("generates encoder function reference", () => {
      const node = definedTypeLinkNode("myCustomType");
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toBe("getMyCustomTypeEncoder()");
    });

    it("generates decoder function reference", () => {
      const node = definedTypeLinkNode("myCustomType");
      const manifest = visit(node, createVisitor());
      expect(manifest.decoder.content).toBe("getMyCustomTypeDecoder()");
    });

    it("defaults isEnum to true (assumed scalar unless in nonScalarEnums)", () => {
      const node = definedTypeLinkNode("myEnum");
      const manifest = visit(node, createVisitor());
      expect(manifest.isEnum).toBe(true);
    });

    it("marks as non-enum when name is in nonScalarEnums list", () => {
      const visitor = getTypeManifestVisitor({
        nameApi: createDartNameApi(),
        linkables: new LinkableDictionary(),
        stack: new NodeStack(),
        nonScalarEnums: ["myEnum" as any],
      });
      const node = definedTypeLinkNode("myEnum");
      const manifest = visit(node, visitor);
      expect(manifest.isEnum).toBe(false);
    });
  });

  describe("mapTypeNode", () => {
    it("maps to Map<K, V> type", () => {
      const node = mapTypeNode(
        stringTypeNode("utf8"),
        numberTypeNode("u32"),
        prefixedCountNode(numberTypeNode("u32")),
      );
      const manifest = visit(node, createVisitor());
      expect(manifest.type.content).toBe("Map<String, int>");
    });

    it("uses getMapEncoder/Decoder", () => {
      const node = mapTypeNode(
        stringTypeNode("utf8"),
        numberTypeNode("u32"),
        prefixedCountNode(numberTypeNode("u32")),
      );
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toContain("getMapEncoder");
      expect(manifest.decoder.content).toContain("getMapDecoder");
    });
  });

  describe("setTypeNode", () => {
    it("maps to Set<T> type", () => {
      const node = setTypeNode(
        numberTypeNode("u8"),
        prefixedCountNode(numberTypeNode("u32")),
      );
      const manifest = visit(node, createVisitor());
      expect(manifest.type.content).toBe("Set<int>");
    });

    it("uses getSetEncoder/Decoder", () => {
      const node = setTypeNode(
        numberTypeNode("u8"),
        prefixedCountNode(numberTypeNode("u32")),
      );
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toContain("getSetEncoder");
      expect(manifest.decoder.content).toContain("getSetDecoder");
    });
  });

  describe("tupleTypeNode", () => {
    it("maps to a Dart record type", () => {
      const node = tupleTypeNode([
        numberTypeNode("u8"),
        stringTypeNode("utf8"),
      ]);
      const manifest = visit(node, createVisitor());
      expect(manifest.type.content).toBe("(int, String)");
    });

    it("uses getTupleEncoder/Decoder", () => {
      const node = tupleTypeNode([
        numberTypeNode("u8"),
        numberTypeNode("u32"),
      ]);
      const manifest = visit(node, createVisitor());
      expect(manifest.encoder.content).toContain("getTupleEncoder");
      expect(manifest.decoder.content).toContain("getTupleDecoder");
    });
  });
});
