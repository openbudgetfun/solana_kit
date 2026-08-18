import {
  constantDiscriminatorNode,
  constantValueNode,
  fieldDiscriminatorNode,
  instructionArgumentNode,
  instructionNode,
  numberTypeNode,
  numberValueNode,
  sizeDiscriminatorNode,
} from "@codama/nodes";
import { LinkableDictionary, NodeStack } from "@codama/visitors-core";
import { describe, expect, it } from "vitest";

import { getDiscriminatorValidationFragment } from "../../src/utils/discriminators.js";
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

describe("getDiscriminatorValidationFragment", () => {
  it("rejects field discriminators without defaults", () => {
    const node = instructionNode({
      name: "invalid",
      arguments: [
        instructionArgumentNode({
          name: "discriminator",
          type: numberTypeNode("u8"),
        }),
      ],
      discriminators: [fieldDiscriminatorNode("discriminator", 0)],
    });

    expect(() =>
      getDiscriminatorValidationFragment(node, createScope())
    ).toThrow(/must reference a field with a default value/);
  });

  it("rejects negative discriminator sizes", () => {
    const node = instructionNode({
      name: "invalid",
      arguments: [],
      discriminators: [sizeDiscriminatorNode(-1)],
    });

    expect(() =>
      getDiscriminatorValidationFragment(node, createScope())
    ).toThrow(/size must be a non-negative safe integer/);
  });

  it("rejects negative discriminator offsets", () => {
    const node = instructionNode({
      name: "invalid",
      arguments: [],
      discriminators: [
        constantDiscriminatorNode(
          constantValueNode(numberTypeNode("u8"), numberValueNode(1)),
          -1,
        ),
      ],
    });

    expect(() =>
      getDiscriminatorValidationFragment(node, createScope())
    ).toThrow(/offset must be a non-negative safe integer/);
  });
});
