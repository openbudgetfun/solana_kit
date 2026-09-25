import {
  accountBumpValueNode,
  bytesTypeNode,
  bytesValueNode,
  constantDiscriminatorNode,
  constantValueNode,
  fieldDiscriminatorNode,
  instructionAccountNode,
  instructionArgumentNode,
  instructionNode,
  numberTypeNode,
  numberValueNode,
  optionTypeNode,
  publicKeyTypeNode,
  publicKeyValueNode,
  sizeDiscriminatorNode,
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

  it("uses program address placeholders for optional accounts by default", () => {
    const node = {
      ...instructionNode({
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
      }),
      // The node helper inserts `programId`, so explicitly model serialized
      // nodes from schemas that omit the optional account strategy.
      optionalAccountStrategy: undefined,
    };
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain(
      "if (optionalAccount != null) AccountMeta(address: optionalAccount, role: AccountRole.readonly) else AccountMeta(address: programAddress, role: AccountRole.readonly)",
    );
  });

  it("only removes optional account slots for the omitted strategy", () => {
    const node = instructionNode({
      name: "myInstruction",
      optionalAccountStrategy: "omitted",
      accounts: [
        instructionAccountNode({
          name: "optionalAccount",
          isSigner: false,
          isWritable: true,
          isOptional: true,
        }),
      ],
      arguments: [],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain(
      "if (optionalAccount != null) AccountMeta(address: optionalAccount, role: AccountRole.writable)",
    );
    expect(frag.content).not.toContain("else AccountMeta");
  });

  it("rejects unsupported optional account strategies", () => {
    const node = instructionNode({
      name: "myInstruction",
      optionalAccountStrategy: "unknown" as never,
      accounts: [],
      arguments: [],
    });

    expect(() => getInstructionPageFragment(node, createScope())).toThrow(
      /Unsupported optional account strategy.*unknown/,
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
    expect(frag.content).toContain("newOffset != bytes.length");
    expect(frag.content).toContain(
      "FixedSizeDecoder<Map<String, Object?>>()",
    );
    expect(frag.content).toContain(
      "VariableSizeDecoder<Map<String, Object?>>()",
    );
  });

  it("decodes nullable instruction arguments without a non-null assertion", () => {
    const node = instructionNode({
      name: "transferMaybe",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "amount",
          type: optionTypeNode(numberTypeNode("u64")),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain(
      "amount: map['amount'] as BigInt?,",
    );
    expect(frag.content).not.toContain(
      "amount: map['amount']! as BigInt?,",
    );
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

  it("initializes non-const discriminator defaults inside the constructor", () => {
    const node = instructionNode({
      name: "verifyBytes",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "discriminator",
          type: bytesTypeNode(),
          defaultValue: bytesValueNode("base16", "aabb"),
        }),
      ],
      discriminators: [fieldDiscriminatorNode("discriminator")],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain("Uint8List? discriminator,");
    expect(frag.content).toContain(
      "discriminator = discriminator ?? Uint8List.fromList([0xaa, 0xbb])",
    );
    expect(frag.content).not.toContain("const VerifyBytesInstructionData");
  });

  it("requires account bump arguments instead of rendering async defaults", () => {
    const node = instructionNode({
      name: "createLookupTable",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "bump",
          type: numberTypeNode("u8"),
          defaultValue: accountBumpValueNode("lookupTable"),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain("required int bump,");
    expect(frag.content).toContain("bump: bump,");
    expect(frag.content).not.toContain("bump ??");
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

  it("uses well-known address name for publicKeyValueNode default", () => {
    const node = instructionNode({
      name: "createAccount",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "owner",
          type: publicKeyTypeNode(),
          defaultValue: publicKeyValueNode(
            "11111111111111111111111111111111",
          ),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    // well-known address should emit canonical constant name
    expect(frag.content).toContain("systemProgramAddress");
    // should not emit Address('1111...') for a known address
    expect(frag.content).not.toContain(
      "Address('11111111111111111111111111111111')",
    );
  });

  it("uses Address fallback for unknown publicKeyValueNode default", () => {
    const node = instructionNode({
      name: "createAccount",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "owner",
          type: publicKeyTypeNode(),
          defaultValue: publicKeyValueNode(
            "UnknownProgram1111111111111111111111",
          ),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    // unknown address should fall back to Address('...')
    expect(frag.content).toContain(
      "Address('UnknownProgram1111111111111111111111')",
    );
  });

  it("renders BigInt defaults for wide numeric arguments", () => {
    const node = instructionNode({
      name: "transfer",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "amount",
          type: numberTypeNode("u64"),
          defaultValue: numberValueNode(3),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain("amount: amount ?? BigInt.from(3),");
  });

  it("renders plain number defaults for narrow numeric arguments", () => {
    const node = instructionNode({
      name: "transfer",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "amount",
          type: numberTypeNode("u8"),
          defaultValue: numberValueNode(3),
        }),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain("amount: amount ?? 3,");
  });

  it("owns omitted defaults and validates all discriminator kinds", () => {
    const discriminatorType = numberTypeNode("u8");
    const node = instructionNode({
      name: "verify",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "discriminator",
          type: discriminatorType,
          defaultValue: numberValueNode(9),
          defaultValueStrategy: "omitted",
        }),
        instructionArgumentNode({
          name: "amount",
          type: numberTypeNode("u16"),
        }),
      ],
      discriminators: [
        constantDiscriminatorNode(
          constantValueNode(discriminatorType, numberValueNode(9)),
          0,
        ),
        sizeDiscriminatorNode(3),
      ],
    });
    const frag = getInstructionPageFragment(node, createScope());

    expect(frag.content).toContain("discriminator = 9");
    expect(frag.content).not.toContain("Address? discriminator");
    expect(frag.content).toContain("'discriminator': 9,");
    expect(frag.content).toContain("getConstantDecoder(");
    expect(frag.content).toContain("bytes.length - offset != 3");
  });

  it("rejects field discriminators without deterministic defaults", () => {
    const node = instructionNode({
      name: "invalid",
      accounts: [],
      arguments: [
        instructionArgumentNode({
          name: "discriminator",
          type: numberTypeNode("u8"),
        }),
      ],
      discriminators: [fieldDiscriminatorNode("discriminator", 0)],
    });

    expect(() => getInstructionPageFragment(node, createScope())).toThrow(
      /must reference a field with a default value/,
    );
  });
});
