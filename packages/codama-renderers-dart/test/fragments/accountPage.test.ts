import {
  accountNode,
  constantDiscriminatorNode,
  constantValueNode,
  fieldDiscriminatorNode,
  numberTypeNode,
  numberValueNode,
  optionTypeNode,
  publicKeyTypeNode,
  structFieldTypeNode,
  structTypeNode,
} from "@codama/nodes";
import { LinkableDictionary, NodeStack } from "@codama/visitors-core";
import { describe, expect, it } from "vitest";

import { getAccountPageFragment } from "../../src/fragments/accountPage.js";
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

describe("getAccountPageFragment", () => {
  it("generates a class with the correct name", () => {
    const node = accountNode({
      name: "tokenAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("class TokenAccount");
  });

  it("generates field declarations", () => {
    const node = accountNode({
      name: "tokenAccount",
      data: structTypeNode([
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
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("final BigInt amount;");
    expect(frag.content).toContain("final Address owner;");
  });

  it("generates const constructor with required params", () => {
    const node = accountNode({
      name: "tokenAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("const TokenAccount({");
    expect(frag.content).toContain("required this.amount,");
  });

  it("generates encoder function", () => {
    const node = accountNode({
      name: "tokenAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain(
      "Encoder<TokenAccount> getTokenAccountEncoder()",
    );
    expect(frag.content).toContain("getStructEncoder");
    expect(frag.content).toContain("transformEncoder");
  });

  it("generates decoder function", () => {
    const node = accountNode({
      name: "tokenAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain(
      "Decoder<TokenAccount> getTokenAccountDecoder()",
    );
    expect(frag.content).toContain("getStructDecoder");
    expect(frag.content).toContain("newOffset != bytes.length");
    expect(frag.content).toContain(
      "FixedSizeDecoder<Map<String, Object?>>()",
    );
    expect(frag.content).toContain(
      "VariableSizeDecoder<Map<String, Object?>>()",
    );
  });

  it("generates codec function", () => {
    const node = accountNode({
      name: "tokenAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("getTokenAccountCodec()");
    expect(frag.content).toContain("combineCodec");
  });

  it("generates decode function", () => {
    const node = accountNode({
      name: "tokenAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("decodeTokenAccount(EncodedAccount");
    expect(frag.content).toContain("decodeAccount(encodedAccount");
  });

  it("generates equality comparison", () => {
    const node = accountNode({
      name: "myAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "x",
          type: numberTypeNode("u8"),
        }),
        structFieldTypeNode({
          name: "y",
          type: numberTypeNode("u16"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("operator ==");
    expect(frag.content).toContain("x == other.x");
    expect(frag.content).toContain("y == other.y");
  });

  it("generates hashCode", () => {
    const node = accountNode({
      name: "myAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "x",
          type: numberTypeNode("u8"),
        }),
        structFieldTypeNode({
          name: "y",
          type: numberTypeNode("u16"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("Object.hash(x, y)");
  });

  it("generates toString", () => {
    const node = accountNode({
      name: "myAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "value",
          type: numberTypeNode("u8"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("toString()");
    expect(frag.content).toContain("MyAccount(value: $value)");
  });

  it("generates @immutable annotation", () => {
    const node = accountNode({
      name: "myAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "value",
          type: numberTypeNode("u8"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("@immutable");
  });

  it("includes auto-generated header", () => {
    const node = accountNode({
      name: "myAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "value",
          type: numberTypeNode("u8"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("// Auto-generated. Do not edit.");
  });

  it("generates size constant when account has a size", () => {
    const node = accountNode({
      name: "myAccount",
      size: 100,
      data: structTypeNode([
        structFieldTypeNode({
          name: "data",
          type: numberTypeNode("u8"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("myAccountSize");
    expect(frag.content).toContain("100");
  });

  it("has required imports for account types", () => {
    const node = accountNode({
      name: "tokenAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.imports.modules.has("dartTypedData")).toBe(true);
    expect(frag.imports.modules.has("meta")).toBe(true);
    expect(frag.imports.modules.has("solanaCodecsCore")).toBe(true);
    expect(frag.imports.modules.has("solanaCodecsDataStructures")).toBe(true);
    expect(frag.imports.modules.has("solanaAccounts")).toBe(true);
    // Field type imports should be merged in (u64 requires solanaCodecsNumbers)
    expect(frag.imports.modules.has("solanaCodecsNumbers")).toBe(true);
  });

  it("generates field-specific encoder entries", () => {
    const node = accountNode({
      name: "myAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "balance",
          type: numberTypeNode("u64"),
        }),
        structFieldTypeNode({
          name: "isActive",
          type: numberTypeNode("u8"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("('balance', getU64Encoder())");
    expect(frag.content).toContain("('isActive', getU8Encoder())");
    expect(frag.content).toContain("('balance', getU64Decoder())");
    expect(frag.content).toContain("('isActive', getU8Decoder())");
  });

  it("generates no-arg constructor for empty structs", () => {
    const node = accountNode({
      name: "emptyAccount",
      data: structTypeNode([]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("const EmptyAccount();");
    expect(frag.content).not.toContain("const EmptyAccount({");
  });

  it("generates 'true' equality for empty structs", () => {
    const node = accountNode({
      name: "emptyAccount",
      data: structTypeNode([]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("other is EmptyAccount");
    expect(frag.content).toContain("true");
  });

  it("generates hashCode of 0 for empty structs", () => {
    const node = accountNode({
      name: "emptyAccount",
      data: structTypeNode([]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("int get hashCode => 0;");
  });

  it("generates single-field hashCode without Object.hash", () => {
    const node = accountNode({
      name: "singleFieldAccount",
      data: structTypeNode([
        structFieldTypeNode({
          name: "value",
          type: numberTypeNode("u8"),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("int get hashCode => value.hashCode;");
  });

  it("owns omitted defaults and validates account discriminators", () => {
    const discriminatorType = numberTypeNode("u8");
    const node = accountNode({
      name: "secureState",
      data: structTypeNode([
        structFieldTypeNode({
          name: "discriminator",
          type: discriminatorType,
          defaultValue: numberValueNode(7),
          defaultValueStrategy: "omitted",
        }),
        structFieldTypeNode({
          name: "value",
          type: numberTypeNode("u16"),
        }),
      ]),
      discriminators: [
        constantDiscriminatorNode(
          constantValueNode(discriminatorType, numberValueNode(7)),
          0,
        ),
      ],
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("discriminator = 7");
    expect(frag.content).not.toContain("required this.discriminator");
    expect(frag.content).toContain("'discriminator': 7,");
    expect(frag.content).toContain("getConstantDecoder(");
  });

  it("generates an initializer-only constructor for an omitted-only account", () => {
    const discriminatorType = numberTypeNode("u8");
    const node = accountNode({
      name: "markerState",
      data: structTypeNode([
        structFieldTypeNode({
          name: "discriminator",
          type: discriminatorType,
          defaultValue: numberValueNode(7),
          defaultValueStrategy: "omitted",
        }),
      ]),
      discriminators: [
        constantDiscriminatorNode(
          constantValueNode(discriminatorType, numberValueNode(7)),
          0,
        ),
      ],
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("const MarkerState() : discriminator = 7;");
  });

  it("decodes nullable account fields without a non-null assertion", () => {
    const node = accountNode({
      name: "optionalState",
      data: structTypeNode([
        structFieldTypeNode({
          name: "value",
          type: optionTypeNode(numberTypeNode("u8")),
        }),
      ]),
    });
    const frag = getAccountPageFragment(node, createScope());

    expect(frag.content).toContain("value: map['value'] as int?");
  });

  it("rejects field discriminators without deterministic defaults", () => {
    const node = accountNode({
      name: "invalidState",
      data: structTypeNode([
        structFieldTypeNode({
          name: "discriminator",
          type: numberTypeNode("u8"),
        }),
      ]),
      discriminators: [fieldDiscriminatorNode("discriminator", 0)],
    });

    expect(() => getAccountPageFragment(node, createScope())).toThrow(
      /must have a deterministic default value|must reference a field with a default value/,
    );
  });
});
