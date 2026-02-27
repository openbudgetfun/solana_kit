import {
  accountNode,
  definedTypeNode,
  enumEmptyVariantTypeNode,
  enumTypeNode,
  errorNode,
  instructionAccountNode,
  instructionArgumentNode,
  instructionNode,
  numberTypeNode,
  pdaNode,
  programNode,
  publicKeyTypeNode,
  rootNode,
  structFieldTypeNode,
  structTypeNode,
  variablePdaSeedNode,
} from "@codama/nodes";
import { visit } from "@codama/visitors-core";
import { describe, expect, it } from "vitest";

import { getRenderMapVisitor } from "../../src/visitors/getRenderMapVisitor.js";

describe("getRenderMapVisitor", () => {
  it("generates files for a minimal program", () => {
    const program = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
    });
    const root = rootNode(program);
    const renderMap = visit(root, getRenderMapVisitor());

    // Should have: programs/my_program.dart, programs/programs.dart, my_program.dart (barrel)
    const keys = [...renderMap.keys()];
    expect(keys).toContain("programs/my_program.dart");
    expect(keys).toContain("programs/programs.dart");
    expect(keys).toContain("my_program.dart");
  });

  it("generates account files", () => {
    const program = programNode({
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
      ],
    });
    const root = rootNode(program);
    const renderMap = visit(root, getRenderMapVisitor());
    const keys = [...renderMap.keys()];

    expect(keys).toContain("accounts/token_account.dart");
    expect(keys).toContain("accounts/accounts.dart");
  });

  it("generates instruction files", () => {
    const program = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [
        instructionNode({
          name: "transfer",
          accounts: [
            instructionAccountNode({
              name: "source",
              isSigner: true,
              isWritable: true,
            }),
          ],
          arguments: [
            instructionArgumentNode({
              name: "amount",
              type: numberTypeNode("u64"),
            }),
          ],
        }),
      ],
    });
    const root = rootNode(program);
    const renderMap = visit(root, getRenderMapVisitor());
    const keys = [...renderMap.keys()];

    expect(keys).toContain("instructions/transfer.dart");
    expect(keys).toContain("instructions/instructions.dart");
  });

  it("generates defined type files", () => {
    const program = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      definedTypes: [
        definedTypeNode({
          name: "myStruct",
          type: structTypeNode([
            structFieldTypeNode({
              name: "value",
              type: numberTypeNode("u32"),
            }),
          ]),
        }),
      ],
    });
    const root = rootNode(program);
    const renderMap = visit(root, getRenderMapVisitor());
    const keys = [...renderMap.keys()];

    expect(keys).toContain("types/my_struct.dart");
    expect(keys).toContain("types/types.dart");
  });

  it("generates error files", () => {
    const program = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      errors: [
        errorNode({
          name: "invalidOwner",
          code: 0,
          message: "Invalid owner",
        }),
      ],
    });
    const root = rootNode(program);
    const renderMap = visit(root, getRenderMapVisitor());
    const keys = [...renderMap.keys()];

    expect(keys).toContain("errors/my_program.dart");
    expect(keys).toContain("errors/errors.dart");
  });

  it("generates PDA files", () => {
    const program = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      pdas: [
        pdaNode({
          name: "metadata",
          seeds: [
            variablePdaSeedNode("mint", publicKeyTypeNode()),
          ],
        }),
      ],
    });
    const root = rootNode(program);
    const renderMap = visit(root, getRenderMapVisitor());
    const keys = [...renderMap.keys()];

    expect(keys).toContain("pdas/metadata.dart");
    expect(keys).toContain("pdas/pdas.dart");
  });

  it("generates barrel export for root", () => {
    const program = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      accounts: [
        accountNode({
          name: "token",
          data: structTypeNode([
            structFieldTypeNode({
              name: "amount",
              type: numberTypeNode("u64"),
            }),
          ]),
        }),
      ],
      errors: [
        errorNode({ name: "fail", code: 1, message: "Fail" }),
      ],
    });
    const root = rootNode(program);
    const renderMap = visit(root, getRenderMapVisitor());
    const keys = [...renderMap.keys()];

    // Root barrel should exist
    expect(keys).toContain("my_program.dart");

    // Check barrel content references categories
    const rootBarrel = renderMap.get("my_program.dart");
    expect(rootBarrel).toBeDefined();
    expect(rootBarrel!.content).toContain("accounts/accounts.dart");
    expect(rootBarrel!.content).toContain("programs/programs.dart");
    expect(rootBarrel!.content).toContain("errors/errors.dart");
  });

  it("generates correct file names with snake_case", () => {
    const program = programNode({
      name: "tokenMetadataProgram",
      publicKey: "TokenMetadata1111111111111111111111111111111",
      accounts: [
        accountNode({
          name: "masterEditionV2",
          data: structTypeNode([
            structFieldTypeNode({
              name: "supply",
              type: numberTypeNode("u64"),
            }),
          ]),
        }),
      ],
    });
    const root = rootNode(program);
    const renderMap = visit(root, getRenderMapVisitor());
    const keys = [...renderMap.keys()];

    expect(keys).toContain("accounts/master_edition_v2.dart");
    expect(keys).toContain("programs/token_metadata_program.dart");
    expect(keys).toContain("token_metadata_program.dart");
  });

  it("handles a program with all categories", () => {
    const program = programNode({
      name: "fullProgram",
      publicKey: "Full1111111111111111111111111111111111111111",
      accounts: [
        accountNode({
          name: "myAccount",
          data: structTypeNode([
            structFieldTypeNode({
              name: "data",
              type: numberTypeNode("u8"),
            }),
          ]),
        }),
      ],
      instructions: [
        instructionNode({
          name: "doSomething",
          accounts: [],
          arguments: [],
        }),
      ],
      definedTypes: [
        definedTypeNode({
          name: "myEnum",
          type: enumTypeNode([
            enumEmptyVariantTypeNode("a"),
            enumEmptyVariantTypeNode("b"),
          ]),
        }),
      ],
      errors: [
        errorNode({ name: "oops", code: 42, message: "Oops" }),
      ],
      pdas: [
        pdaNode({
          name: "myPda",
          seeds: [variablePdaSeedNode("key", publicKeyTypeNode())],
        }),
      ],
    });
    const root = rootNode(program);
    const renderMap = visit(root, getRenderMapVisitor());
    const keys = [...renderMap.keys()];

    // All categories present
    expect(keys).toContain("accounts/my_account.dart");
    expect(keys).toContain("accounts/accounts.dart");
    expect(keys).toContain("instructions/do_something.dart");
    expect(keys).toContain("instructions/instructions.dart");
    expect(keys).toContain("types/my_enum.dart");
    expect(keys).toContain("types/types.dart");
    expect(keys).toContain("errors/full_program.dart");
    expect(keys).toContain("errors/errors.dart");
    expect(keys).toContain("pdas/my_pda.dart");
    expect(keys).toContain("pdas/pdas.dart");
    expect(keys).toContain("programs/full_program.dart");
    expect(keys).toContain("programs/programs.dart");
    expect(keys).toContain("full_program.dart");
  });
});
