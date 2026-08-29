import {
  arrayTypeNode,
  enumStructVariantTypeNode,
  enumTypeNode,
  instructionAccountNode,
  instructionArgumentNode,
  instructionNode,
  numberTypeNode,
  publicKeyTypeNode,
  stringTypeNode,
  structFieldTypeNode,
  structTypeNode,
} from "@codama/nodes";
import { LinkableDictionary, NodeStack } from "@codama/visitors-core";
import { describe, expect, it } from "vitest";

import { getInstructionPageFragment } from "../../src/fragments/instructionPage.js";
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

import { getInstructionPageFragment } from "../../src/fragments/instructionPage.js";
import { getTypePageFragment } from "../../src/fragments/typePage.js";

describe("list-field deep equality and hashing", () => {
  it("emits _listEquals/_listHashCode for struct list fields", () => {
    const node = {
      kind: "definedTypeNode",
      name: "basket",
      type: structTypeNode([
        structFieldTypeNode({
          name: "items",
          type: arrayTypeNode(publicKeyTypeNode()),
        }),
        structFieldTypeNode({
          name: "count",
          type: numberTypeNode("u32"),
        }),
      ]),
    } as const;
    const frag = getTypePageFragment(node, createScope());

    expect(frag.content).toContain("_listEquals(items, other.items)");
    expect(frag.content).toContain("_listHashCode(items)");
    // Non-list fields keep the plain comparisons.
    expect(frag.content).toContain("bool _listEquals<T>(List<T>? a, List<T>? b)");
    expect(frag.content).toContain("int _listHashCode<T>(List<T>? a)");
  });

  it("emits _listEquals/_listHashCode inside enum struct variants", () => {
    // Enum data variants with list fields exercise the variant-class branch.
    const node = {
      kind: "definedTypeNode",
      name: "shapeEnum",
      type: enumTypeNode([
        enumStructVariantTypeNode(
          "full",
          structTypeNode([
            structFieldTypeNode({
              name: "points",
              type: arrayTypeNode(numberTypeNode("u32")),
            }),
            structFieldTypeNode({
              name: "label",
              type: stringTypeNode("utf8"),
            }),
          ]),
        ),
      ]),
    } as const;
    const frag = getTypePageFragment(node, createScope());

    expect(frag.content).toContain("_listEquals(points, other.points)");
    expect(frag.content).toContain("Object.hash(_listHashCode(points), label)");
    expect(frag.content).toContain("bool _listEquals<T>(List<T>? a, List<T>? b)");
  });


  it("emits a single _listHashCode for one-list-field classes", () => {
    const node = {
      kind: "definedTypeNode",
      name: "oneList",
      type: structTypeNode([
        structFieldTypeNode({
          name: "entries",
          type: arrayTypeNode(numberTypeNode("u32")),
        }),
      ]),
    } as const;
    const frag = getTypePageFragment(node, createScope());

    expect(frag.content).toContain("int get hashCode => _listHashCode(entries);");
  });

  it("keeps plain comparisons for structs without list fields", () => {
    const node = {
      kind: "definedTypeNode",
      name: "simple",
      type: structTypeNode([
        structFieldTypeNode({ name: "value", type: numberTypeNode("u32") }),
      ]),
    } as const;
    const frag = getTypePageFragment(node, createScope());

    expect(frag.content).toContain("value == other.value");
    expect(frag.content).not.toContain("_listEquals");
  });
});

describe("instruction data local collision handling", () => {
  it("renames the generated local when an account collides", () => {
    const node = instructionNode({
      name: "burn",
      accounts: [
        instructionAccountNode({
          name: "instructionData",
          isSigner: false,
          isWritable: true,
        }),
      ],
      arguments: [],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain("required Address instructionData,");
    expect(frag.content).toContain("final instructionData_ = ");
  });

  it("renames the generated local when an argument collides", () => {
    const node = instructionNode({
      name: "execute",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "instructionData",
          type: publicKeyTypeNode(),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    // The parameter keeps the IDL name; the local gets an underscore suffix.
    expect(frag.content).toContain("required Address instructionData,");
    expect(frag.content).toContain("final instructionData_ = ");
    expect(frag.content).toContain(
      ".encode(instructionData_)",
    );
  });
});