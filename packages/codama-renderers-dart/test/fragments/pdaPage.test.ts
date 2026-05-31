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
});