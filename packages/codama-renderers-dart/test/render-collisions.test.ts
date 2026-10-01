import {
  accountNode,
  definedTypeNode,
  instructionAccountNode,
  instructionNode,
  numberTypeNode,
  programNode,
  rootNode,
  structFieldTypeNode,
  structTypeNode,
} from "@codama/nodes";
import { visit } from "@codama/visitors-core";
import { describe, expect, it } from "vitest";

import { getRenderMapVisitor } from "../src/visitors/getRenderMapVisitor.js";

const address = "11111111111111111111111111111111";

describe("render path collisions", () => {
  it("rejects instructions that collide across programs", () => {
    const first = programNode({
      name: "firstProgram",
      publicKey: address,
      instructions: [
        instructionNode({
          name: "transfer",
          accounts: [
            instructionAccountNode({
              name: "authority",
              isSigner: true,
              isWritable: false,
            }),
          ],
        }),
      ],
    });
    const second = programNode({
      name: "secondProgram",
      publicKey: address,
      instructions: [
        instructionNode({
          name: "transfer",
          accounts: [
            instructionAccountNode({
              name: "authority",
              isSigner: false,
              isWritable: false,
            }),
          ],
        }),
      ],
    });
    const firstSource = visit(
      rootNode(first),
      getRenderMapVisitor(),
    ).get("instructions/transfer.dart")?.content;
    const secondSource = visit(
      rootNode(second),
      getRenderMapVisitor(),
    ).get("instructions/transfer.dart")?.content;

    expect(firstSource).toContain("AccountRole.readonlySigner");
    expect(secondSource).toContain("AccountRole.readonly");
    expect(secondSource).not.toContain("AccountRole.readonlySigner");

    expect(() =>
      visit(rootNode(first, [second]), getRenderMapVisitor())
    ).toThrow('Duplicate generated path "instructions/transfer.dart"');
  });

  it("rejects duplicate types in one program", () => {
    const program = programNode({
      name: "duplicateTypes",
      publicKey: address,
      definedTypes: [
        definedTypeNode({ name: "state", type: structTypeNode([]) }),
        definedTypeNode({
          name: "state",
          type: structTypeNode([
            structFieldTypeNode({
              name: "balance",
              type: numberTypeNode("u64"),
            }),
          ]),
        }),
      ],
    });

    expect(() => visit(rootNode(program), getRenderMapVisitor())).toThrow(
      'Duplicate generated path "types/state.dart"',
    );
  });

  it("rejects node names reserved for category barrels", () => {
    const program = programNode({
      name: "reservedName",
      publicKey: address,
      accounts: [
        accountNode({ name: "accounts", data: structTypeNode([]) }),
      ],
    });

    expect(() => visit(rootNode(program), getRenderMapVisitor())).toThrow(
      'Duplicate generated path "accounts/accounts.dart"',
    );
  });

  it("rejects program names reserved for the programs barrel", () => {
    const program = programNode({ name: "programs", publicKey: address });

    expect(() => visit(rootNode(program), getRenderMapVisitor())).toThrow(
      'Duplicate generated path "programs/programs.dart"',
    );
  });

  it("renders distinct programs and constructs each category barrel once", () => {
    const first = programNode({
      name: "firstProgram",
      publicKey: address,
      instructions: [instructionNode({ name: "deposit" })],
    });
    const second = programNode({
      name: "secondProgram",
      publicKey: address,
      instructions: [instructionNode({ name: "withdraw" })],
    });

    const renderMap = visit(
      rootNode(first, [second]),
      getRenderMapVisitor(),
    );

    expect([...renderMap.keys()]).toEqual(
      expect.arrayContaining([
        "first_program.dart",
        "second_program.dart",
        "instructions/deposit.dart",
        "instructions/withdraw.dart",
        "instructions/instructions.dart",
      ]),
    );
    expect(renderMap.get("instructions/instructions.dart")?.content).toContain(
      "deposit.dart",
    );
    expect(renderMap.get("instructions/instructions.dart")?.content).toContain(
      "withdraw.dart",
    );
  });
});
