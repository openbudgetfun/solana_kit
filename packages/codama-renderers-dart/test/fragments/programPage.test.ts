import {
  accountNode,
  instructionNode,
  numberTypeNode,
  programNode,
  structFieldTypeNode,
  structTypeNode,
} from "@codama/nodes";
import { LinkableDictionary, NodeStack } from "@codama/visitors-core";
import { describe, expect, it } from "vitest";

import { getProgramPageFragment } from "../../src/fragments/programPage.js";
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

describe("getProgramPageFragment", () => {
  it("generates program address constant", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain("myProgramProgramAddress");
    expect(frag.content).toContain("MyProgram1111111111111111111111111111111111");
    expect(frag.content).toContain("const myProgramProgramAddress = Address(");
  });

  it("generates account enum when accounts are present", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      accounts: [
        accountNode({
          name: "tokenAccount",
          data: structTypeNode([
            structFieldTypeNode({
              name: "amount",
              type: numberTypeNode("u64"),
            }),
          ]),
        }),
        accountNode({
          name: "mintAccount",
          data: structTypeNode([
            structFieldTypeNode({
              name: "supply",
              type: numberTypeNode("u64"),
            }),
          ]),
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain("enum MyProgramAccount {");
    expect(frag.content).toContain("tokenAccount,");
    expect(frag.content).toContain("mintAccount,");
  });

  it("generates instruction enum when instructions are present", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [
        instructionNode({
          name: "transfer",
          accounts: [],
          arguments: [],
        }),
        instructionNode({
          name: "initialize",
          accounts: [],
          arguments: [],
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain("enum MyProgramInstruction {");
    expect(frag.content).toContain("transfer,");
    expect(frag.content).toContain("initialize,");
  });

  it("does not generate account enum when no accounts", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).not.toContain("enum MyProgramAccount");
  });

  it("does not generate instruction enum when no instructions", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).not.toContain("enum MyProgramInstruction");
  });

  it("includes auto-generated header", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain("// Auto-generated. Do not edit.");
  });

  it("adds solanaAddresses import for Address", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.imports.modules.has("solanaAddresses")).toBe(true);
  });

  it("includes documentation comment for program address", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain(
      "/// The address of the MyProgram program.",
    );
  });

  it("includes documentation comment for account enum", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      accounts: [
        accountNode({
          name: "myAccount",
          data: structTypeNode([
            structFieldTypeNode({
              name: "value",
              type: numberTypeNode("u8"),
            }),
          ]),
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain(
      "/// Known accounts for the MyProgram program.",
    );
  });

  it("includes documentation comment for instruction enum", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [
        instructionNode({
          name: "doStuff",
          accounts: [],
          arguments: [],
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain(
      "/// Known instructions for the MyProgram program.",
    );
  });
});
