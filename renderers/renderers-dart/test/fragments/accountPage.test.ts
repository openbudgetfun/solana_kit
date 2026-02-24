import {
  accountNode,
  numberTypeNode,
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
    expect(frag.content).toContain("transformDecoder");
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
});
