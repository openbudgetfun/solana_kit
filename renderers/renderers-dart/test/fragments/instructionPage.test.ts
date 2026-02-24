import {
  fieldDiscriminatorNode,
  instructionAccountNode,
  instructionArgumentNode,
  instructionNode,
  numberTypeNode,
  numberValueNode,
  publicKeyTypeNode,
} from "@codama/nodes";
import { LinkableDictionary, NodeStack } from "@codama/visitors-core";
import { describe, expect, it } from "vitest";

import { getInstructionPageFragment } from "../../src/fragments/instructionPage.js";
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

describe("getInstructionPageFragment", () => {
  it("generates instruction data class", () => {
    const node = instructionNode({
      name: "transfer",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain("class TransferInstructionData");
    expect(frag.content).toContain("final BigInt amount;");
  });

  it("generates instruction builder function", () => {
    const node = instructionNode({
      name: "transfer",
      accounts: [
        instructionAccountNode({
          name: "source",
          isSigner: true,
          isWritable: true,
        }),
        instructionAccountNode({
          name: "destination",
          isSigner: false,
          isWritable: true,
        }),
      ],
      arguments: [
        instructionArgumentNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain("Instruction getTransferInstruction(");
    expect(frag.content).toContain("required Address programAddress,");
    // Account params reference the account addresses
    expect(frag.content).toContain("AccountMeta(address: source,");
    expect(frag.content).toContain("AccountMeta(address: destination,");
    expect(frag.content).toContain("required BigInt amount,");
  });

  it("generates account metas with correct roles", () => {
    const node = instructionNode({
      name: "transfer",
      accounts: [
        instructionAccountNode({
          name: "signer",
          isSigner: true,
          isWritable: false,
        }),
        instructionAccountNode({
          name: "writable",
          isSigner: false,
          isWritable: true,
        }),
        instructionAccountNode({
          name: "signerWritable",
          isSigner: true,
          isWritable: true,
        }),
        instructionAccountNode({
          name: "readonly",
          isSigner: false,
          isWritable: false,
        }),
      ],
      arguments: [],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain("AccountRole.readonlySigner");
    expect(frag.content).toContain("AccountRole.writable");
    expect(frag.content).toContain("AccountRole.writableSigner");
    expect(frag.content).toContain("AccountRole.readonly");
  });

  it("handles optional accounts", () => {
    const node = instructionNode({
      name: "myInstruction",
      accounts: [
        instructionAccountNode({
          name: "optionalAccount",
          isSigner: false,
          isWritable: false,
          isOptional: true,
        }),
      ],
      arguments: [],
    });
    const frag = getInstructionPageFragment(node, createScope());

    // The account meta uses conditional inclusion for optional accounts
    expect(frag.content).toContain("if (optionalAccount != null)");
    expect(frag.content).toContain(
      "AccountMeta(address: optionalAccount, role: AccountRole.readonly)",
    );
  });

  it("generates data encoder function", () => {
    const node = instructionNode({
      name: "transfer",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain(
      "Encoder<TransferInstructionData> getTransferInstructionDataEncoder()",
    );
    expect(frag.content).toContain("getStructEncoder");
    expect(frag.content).toContain("transformEncoder");
  });

  it("generates data decoder function", () => {
    const node = instructionNode({
      name: "transfer",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain(
      "Decoder<TransferInstructionData> getTransferInstructionDataDecoder()",
    );
    expect(frag.content).toContain("getStructDecoder");
    expect(frag.content).toContain("transformDecoder");
  });

  it("generates data codec function", () => {
    const node = instructionNode({
      name: "transfer",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain("getTransferInstructionDataCodec()");
    expect(frag.content).toContain("combineCodec");
  });

  it("generates parse function", () => {
    const node = instructionNode({
      name: "transfer",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain(
      "TransferInstructionData parseTransferInstruction(Instruction instruction)",
    );
    expect(frag.content).toContain(
      "getTransferInstructionDataDecoder().decode(instruction.data!)",
    );
  });

  it("handles discriminator arguments with defaults", () => {
    const node = instructionNode({
      name: "transfer",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "discriminator",
          type: numberTypeNode("u8"),
          defaultValue: numberValueNode(3),
        }),
        instructionArgumentNode({
          name: "amount",
          type: numberTypeNode("u64"),
        }),
      ],
      discriminators: [fieldDiscriminatorNode("discriminator")],
    });
    const frag = getInstructionPageFragment(node, createScope());

    // Discriminator arg should have a default value in the constructor
    expect(frag.content).toContain("this.discriminator = 3,");
    // The builder function should not require discriminator as a param
    // (it uses the default)
    expect(frag.content).toContain("required BigInt amount,");
  });

  it("includes auto-generated header", () => {
    const node = instructionNode({
      name: "transfer",
      accounts: [],
      arguments: [],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain("// Auto-generated. Do not edit.");
  });

  it("has required imports", () => {
    const node = instructionNode({
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
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.imports.modules.has("solanaCodecsCore")).toBe(true);
    expect(frag.imports.modules.has("solanaCodecsDataStructures")).toBe(true);
    expect(frag.imports.modules.has("solanaAddresses")).toBe(true);
    expect(frag.imports.modules.has("solanaInstructions")).toBe(true);
    // Arg type imports should be merged in (u64 requires solanaCodecsNumbers)
    expect(frag.imports.modules.has("solanaCodecsNumbers")).toBe(true);
  });

  it("handles instruction with no arguments", () => {
    const node = instructionNode({
      name: "initialize",
      accounts: [
        instructionAccountNode({
          name: "payer",
          isSigner: true,
          isWritable: true,
        }),
      ],
      arguments: [],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain("class InitializeInstructionData");
    expect(frag.content).toContain("Instruction getInitializeInstruction(");
  });
});
