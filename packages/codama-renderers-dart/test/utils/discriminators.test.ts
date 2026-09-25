import {
  accountNode,
  constantDiscriminatorNode,
  constantValueNode,
  fieldDiscriminatorNode,
  instructionArgumentNode,
  instructionNode,
  numberTypeNode,
  numberValueNode,
  sizeDiscriminatorNode,
  structTypeNode,
} from "@codama/nodes";
import type { AccountNode, InstructionNode } from "@codama/nodes";
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

  it("treats omitted account fields as empty", () => {
    const account = accountNode({
      name: "empty",
      data: structTypeNode([]),
      discriminators: [fieldDiscriminatorNode("discriminator", 0)],
    });
    const node = {
      ...account,
      data: { ...account.data, fields: undefined },
    } as unknown as AccountNode;

    expect(() =>
      getDiscriminatorValidationFragment(node, createScope())
    ).toThrow(/must reference a field with a default value/);
  });

  it("treats omitted instruction arguments as empty", () => {
    const node = {
      ...instructionNode({
        name: "empty",
        discriminators: [fieldDiscriminatorNode("discriminator", 0)],
      }),
      arguments: undefined,
    } as unknown as InstructionNode;

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

  it("requires an exact instruction size but only a minimum account size", () => {
    // An instruction's discriminated size is the whole payload. An account's is
    // its fixed prefix: accounts with variable trailing fields (a TLV extension
    // region, for example) are legitimately longer.
    const instruction = instructionNode({
      name: "verify",
      arguments: [],
      discriminators: [sizeDiscriminatorNode(3)],
    });
    const account = accountNode({
      name: "tokenAccount",
      data: structTypeNode([
        {
          kind: "structFieldTypeNode",
          name: "amount",
          type: numberTypeNode("u64"),
        },
      ]),
      discriminators: [sizeDiscriminatorNode(165)],
    });

    expect(
      getDiscriminatorValidationFragment(instruction, createScope()).content
    ).toContain("bytes.length - offset != 3");
    expect(
      getDiscriminatorValidationFragment(account, createScope()).content
    ).toContain("bytes.length - offset < 165");
  });
});
