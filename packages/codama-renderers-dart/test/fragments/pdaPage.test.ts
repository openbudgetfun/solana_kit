import {
  constantPdaSeedNodeFromString,
  pdaNode,
  publicKeyTypeNode,
  variablePdaSeedNode,
} from "@codama/nodes";
import { LinkableDictionary, NodeStack } from "@codama/visitors-core";
import { describe, expect, it } from "vitest";

import { getPdaPageFragment } from "../../src/fragments/pdaPage.js";
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

describe("getPdaPageFragment", () => {
  it("uses well-known address for programId parameter", () => {
    const node = pdaNode({
      name: "testPda",
      seeds: [
        constantPdaSeedNodeFromString("utf8", "seed"),
        variablePdaSeedNode("authority", publicKeyTypeNode()),
      ],
      programId: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
    });
    const frag = getPdaPageFragment(node, createScope());

    // Program address default should use canonical name
    expect(frag.content).toContain("tokenProgramAddress");
    // Should not embed the raw address string in an Address() constructor
    expect(frag.content).not.toContain(
      "Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA')",
    );
  });

  it("uses Address fallback for unknown programId", () => {
    const node = pdaNode({
      name: "testPda",
      seeds: [
        constantPdaSeedNodeFromString("utf8", "seed"),
        variablePdaSeedNode("authority", publicKeyTypeNode()),
      ],
      programId: "SomeUnknown1111111111111111111111111111",
    });
    const frag = getPdaPageFragment(node, createScope());

    // Unknown program address should use Address('...')
    expect(frag.content).toContain(
      "Address('SomeUnknown1111111111111111111111111111')",
    );
  });

  it("uses required Address when no programId", () => {
    const node = pdaNode({
      name: "testPda",
      seeds: [constantPdaSeedNodeFromString("utf8", "seed")],
    });
    const frag = getPdaPageFragment(node, createScope());

    // No programId means required Address parameter
    expect(frag.content).toContain("required Address programAddress");
  });

  it("uses well-known address name for publicKey seed", () => {
    // Construct PDA with a publicKey seed using a well-known address
    const node = pdaNode({
      name: "testPda",
      seeds: [
        constantPdaSeedNodeFromString("utf8", "seed"),
        // Manually construct the seed to match Codama IDL structure
        {
          kind: "constantPdaSeedNode",
          type: { kind: "publicKeyTypeNode" },
          value: {
            kind: "publicKeyValueNode",
            publicKey: "11111111111111111111111111111111",
          },
        },
      ],
    });
    const frag = getPdaPageFragment(node, createScope());

    // Well-known seed should use canonical constant name (systemProgramAddress)
    expect(frag.content).toContain("systemProgramAddress");
    // Should not fall back to Address('1111...') for a known key
    expect(frag.content).not.toContain(
      "Address('11111111111111111111111111111111')",
    );
  });

  it("uses Address fallback for unknown publicKey seed", () => {
    const node = pdaNode({
      name: "testPda",
      seeds: [
        constantPdaSeedNodeFromString("utf8", "seed"),
        {
          kind: "constantPdaSeedNode",
          type: { kind: "publicKeyTypeNode" },
          value: {
            kind: "publicKeyValueNode",
            publicKey: "UnknownProgram1111111111111111111111",
          },
        },
      ],
    });
    const frag = getPdaPageFragment(node, createScope());

    // Unknown address should fall back to Address('...')
    expect(frag.content).toContain(
      "Address('UnknownProgram1111111111111111111111')",
    );
  });
});