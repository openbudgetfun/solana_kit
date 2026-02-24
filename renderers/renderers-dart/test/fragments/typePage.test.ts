import {
  definedTypeNode,
  enumEmptyVariantTypeNode,
  enumStructVariantTypeNode,
  enumTupleVariantTypeNode,
  enumTypeNode,
  numberTypeNode,
  publicKeyTypeNode,
  stringTypeNode,
  structFieldTypeNode,
  structTypeNode,
  tupleTypeNode,
} from "@codama/nodes";
import { LinkableDictionary, NodeStack } from "@codama/visitors-core";
import { describe, expect, it } from "vitest";

import { getTypePageFragment } from "../../src/fragments/typePage.js";
import { createDartNameApi } from "../../src/utils/nameTransformers.js";
import type { RenderScope } from "../../src/utils/options.js";
import { getTypeManifestVisitor } from "../../src/visitors/getTypeManifestVisitor.js";

function createScope(): RenderScope {
  const nameApi = createDartNameApi();
  const linkables = new LinkableDictionary();
  const stack = new NodeStack();
  return {
    nameApi,
    typeManifestVisitor: getTypeManifestVisitor({
      nameApi,
      linkables,
      stack,
    }),
    linkables,
    dependencyMap: {},
    internalImportMap: {},
  };
}

describe("getTypePageFragment", () => {
  describe("struct types", () => {
    it("generates a Dart class with fields", () => {
      const node = definedTypeNode({
        name: "myStruct",
        type: structTypeNode([
          structFieldTypeNode({
            name: "amount",
            type: numberTypeNode("u64"),
          }),
          structFieldTypeNode({
            name: "owner",
            type: publicKeyTypeNode(),
          }),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("class MyStruct");
      expect(frag.content).toContain("final BigInt amount;");
      expect(frag.content).toContain("final Address owner;");
    });

    it("generates const constructor with required params", () => {
      const node = definedTypeNode({
        name: "simple",
        type: structTypeNode([
          structFieldTypeNode({
            name: "value",
            type: numberTypeNode("u32"),
          }),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("const Simple({");
      expect(frag.content).toContain("required this.value,");
    });

    it("generates encoder function", () => {
      const node = definedTypeNode({
        name: "myStruct",
        type: structTypeNode([
          structFieldTypeNode({
            name: "amount",
            type: numberTypeNode("u64"),
          }),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain(
        "Encoder<MyStruct> getMyStructEncoder()",
      );
      expect(frag.content).toContain("getStructEncoder");
      expect(frag.content).toContain("transformEncoder");
    });

    it("generates decoder function", () => {
      const node = definedTypeNode({
        name: "myStruct",
        type: structTypeNode([
          structFieldTypeNode({
            name: "amount",
            type: numberTypeNode("u64"),
          }),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain(
        "Decoder<MyStruct> getMyStructDecoder()",
      );
      expect(frag.content).toContain("getStructDecoder");
      expect(frag.content).toContain("transformDecoder");
    });

    it("generates codec function", () => {
      const node = definedTypeNode({
        name: "myStruct",
        type: structTypeNode([
          structFieldTypeNode({
            name: "value",
            type: numberTypeNode("u8"),
          }),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("getMyStructCodec()");
      expect(frag.content).toContain("combineCodec");
    });

    it("generates equality and hashCode", () => {
      const node = definedTypeNode({
        name: "myStruct",
        type: structTypeNode([
          structFieldTypeNode({
            name: "x",
            type: numberTypeNode("u8"),
          }),
          structFieldTypeNode({
            name: "y",
            type: numberTypeNode("u8"),
          }),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("operator ==");
      expect(frag.content).toContain("x == other.x");
      expect(frag.content).toContain("y == other.y");
      expect(frag.content).toContain("Object.hash(x, y)");
    });

    it("generates toString method", () => {
      const node = definedTypeNode({
        name: "myStruct",
        type: structTypeNode([
          structFieldTypeNode({
            name: "value",
            type: numberTypeNode("u8"),
          }),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("toString()");
      expect(frag.content).toContain("MyStruct(value: $value)");
    });

    it("adds @immutable annotation", () => {
      const node = definedTypeNode({
        name: "myStruct",
        type: structTypeNode([
          structFieldTypeNode({
            name: "value",
            type: numberTypeNode("u8"),
          }),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("@immutable");
    });

    it("includes auto-generated header", () => {
      const node = definedTypeNode({
        name: "myStruct",
        type: structTypeNode([]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("// Auto-generated. Do not edit.");
      expect(frag.content).toContain("// ignore_for_file: type=lint");
    });
  });

  describe("scalar enum types", () => {
    it("generates a Dart enum with variants", () => {
      const node = definedTypeNode({
        name: "color",
        type: enumTypeNode([
          enumEmptyVariantTypeNode("red"),
          enumEmptyVariantTypeNode("green"),
          enumEmptyVariantTypeNode("blue"),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("enum Color {");
      expect(frag.content).toContain("red,");
      expect(frag.content).toContain("green,");
      expect(frag.content).toContain("blue,");
    });

    it("generates encoder using transformEncoder", () => {
      const node = definedTypeNode({
        name: "status",
        type: enumTypeNode([
          enumEmptyVariantTypeNode("active"),
          enumEmptyVariantTypeNode("inactive"),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("Encoder<Status> getStatusEncoder()");
      expect(frag.content).toContain("transformEncoder");
      expect(frag.content).toContain("value.index");
    });

    it("generates decoder using transformDecoder", () => {
      const node = definedTypeNode({
        name: "status",
        type: enumTypeNode([
          enumEmptyVariantTypeNode("active"),
          enumEmptyVariantTypeNode("inactive"),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("Decoder<Status> getStatusDecoder()");
      expect(frag.content).toContain("transformDecoder");
      expect(frag.content).toContain("Status.values[value.toInt()]");
    });

    it("generates codec function", () => {
      const node = definedTypeNode({
        name: "status",
        type: enumTypeNode([
          enumEmptyVariantTypeNode("active"),
          enumEmptyVariantTypeNode("inactive"),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("getStatusCodec()");
      expect(frag.content).toContain("combineCodec");
    });

    it("uses U8 size codec by default", () => {
      const node = definedTypeNode({
        name: "status",
        type: enumTypeNode([
          enumEmptyVariantTypeNode("active"),
          enumEmptyVariantTypeNode("inactive"),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("getU8Encoder()");
      expect(frag.content).toContain("getU8Decoder()");
    });
  });

  describe("data enum types (sealed classes)", () => {
    it("generates a sealed class", () => {
      const node = definedTypeNode({
        name: "myEnum",
        type: enumTypeNode([
          enumEmptyVariantTypeNode("empty"),
          enumStructVariantTypeNode(
            "withData",
            structTypeNode([
              structFieldTypeNode({
                name: "value",
                type: numberTypeNode("u32"),
              }),
            ]),
          ),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("sealed class MyEnum");
    });

    it("generates empty variant subclass", () => {
      const node = definedTypeNode({
        name: "myEnum",
        type: enumTypeNode([
          enumEmptyVariantTypeNode("none"),
          enumStructVariantTypeNode(
            "some",
            structTypeNode([
              structFieldTypeNode({
                name: "value",
                type: numberTypeNode("u32"),
              }),
            ]),
          ),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain(
        "final class None extends MyEnum",
      );
      expect(frag.content).toContain("const None()");
    });

    it("generates struct variant subclass with fields", () => {
      const node = definedTypeNode({
        name: "payload",
        type: enumTypeNode([
          enumEmptyVariantTypeNode("empty"),
          enumStructVariantTypeNode(
            "data",
            structTypeNode([
              structFieldTypeNode({
                name: "amount",
                type: numberTypeNode("u64"),
              }),
              structFieldTypeNode({
                name: "owner",
                type: publicKeyTypeNode(),
              }),
            ]),
          ),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain(
        "final class Data extends Payload",
      );
      expect(frag.content).toContain("final BigInt amount;");
      expect(frag.content).toContain("final Address owner;");
    });

    it("generates tuple variant subclass", () => {
      const node = definedTypeNode({
        name: "myEnum",
        type: enumTypeNode([
          enumEmptyVariantTypeNode("none"),
          enumTupleVariantTypeNode(
            "single",
            tupleTypeNode([numberTypeNode("u32")]),
          ),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain(
        "final class Single extends MyEnum",
      );
      expect(frag.content).toContain("final int value;");
    });

    it("uses discriminated union encoder/decoder", () => {
      const node = definedTypeNode({
        name: "myEnum",
        type: enumTypeNode([
          enumEmptyVariantTypeNode("a"),
          enumStructVariantTypeNode(
            "b",
            structTypeNode([
              structFieldTypeNode({
                name: "value",
                type: numberTypeNode("u32"),
              }),
            ]),
          ),
        ]),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("getDiscriminatedUnionEncoder");
      expect(frag.content).toContain("getDiscriminatedUnionDecoder");
    });
  });

  describe("type alias types", () => {
    it("generates a typedef for simple types", () => {
      const node = definedTypeNode({
        name: "myAlias",
        type: numberTypeNode("u64"),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("typedef MyAlias = BigInt;");
    });

    it("generates encoder/decoder wrappers", () => {
      const node = definedTypeNode({
        name: "myAlias",
        type: numberTypeNode("u64"),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain(
        "Encoder<MyAlias> getMyAliasEncoder()",
      );
      expect(frag.content).toContain(
        "Decoder<MyAlias> getMyAliasDecoder()",
      );
      expect(frag.content).toContain("getMyAliasCodec()");
    });

    it("handles string type alias", () => {
      const node = definedTypeNode({
        name: "label",
        type: stringTypeNode("utf8"),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("typedef Label = String;");
      expect(frag.content).toContain("getUtf8Encoder");
    });

    it("handles publicKey type alias", () => {
      const node = definedTypeNode({
        name: "owner",
        type: publicKeyTypeNode(),
      });
      const frag = getTypePageFragment(node, createScope());

      expect(frag.content).toContain("typedef Owner = Address;");
      expect(frag.content).toContain("getAddressEncoder");
    });
  });
});
