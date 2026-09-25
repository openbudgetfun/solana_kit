import {
  accountNode,
  booleanTypeNode,
  booleanValueNode,
  bytesTypeNode,
  bytesValueNode,
  constantDiscriminatorNode,
  constantValueNode,
  fieldDiscriminatorNode,
  instructionArgumentNode,
  instructionNode,
  mapTypeNode,
  mapValueNode,
  numberTypeNode,
  numberValueNode,
  programNode,
  sizeDiscriminatorNode,
  stringTypeNode,
  stringValueNode,
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

  it("generates instruction identify and parse helpers", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [
        instructionNode({
          name: "transfer",
          accounts: [],
          arguments: [
            instructionArgumentNode({
              name: "discriminator",
              type: numberTypeNode("u8"),
              defaultValue: numberValueNode(3),
            }),
          ],
          discriminators: [fieldDiscriminatorNode("discriminator", 0)],
        }),
        instructionNode({
          name: "initialize",
          accounts: [],
          arguments: [],
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain(
      "MyProgramInstruction identifyMyProgramInstruction(",
    );
    expect(frag.content).toContain(
      "containsBytes(data, getU8Encoder().encode(3), 0)",
    );
    expect(frag.content).toContain(
      "sealed class ParsedMyProgramInstruction",
    );
    expect(frag.content).toContain(
      "final class ParsedTransfer extends ParsedMyProgramInstruction",
    );
    expect(frag.content).toContain(
      "final TransferInstructionData data;",
    );
    expect(frag.content).toContain(
      "ParsedMyProgramInstruction parseMyProgramInstruction(",
    );
    expect(frag.content).toContain(
      "instruction.data ?? Uint8List(0)",
    );
    expect(frag.content).toContain(
      "MyProgramInstruction.transfer => ParsedTransfer(",
    );
    expect(frag.content).toContain(
      "data: parseTransferInstruction(instruction)",
    );
    expect(frag.content).toContain(
      "MyProgramInstruction.initialize => ParsedInitialize(",
    );
    expect(frag.imports.modules.has("dartTypedData")).toBe(true);
    expect(frag.imports.modules.has("solanaCodecsCore")).toBe(true);
    expect(frag.imports.modules.has("solanaErrors")).toBe(true);
    expect(frag.imports.modules.has("solanaInstructions")).toBe(true);
    expect(
      frag.imports.modules.has("../instructions/instructions.dart"),
    ).toBe(true);
  });

  it("uses BigInt values for wide numeric discriminators", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [
        instructionNode({
          name: "transfer",
          accounts: [],
          arguments: [
            instructionArgumentNode({
              name: "discriminator",
              type: numberTypeNode("u64"),
              defaultValue: numberValueNode(3),
            }),
          ],
          discriminators: [fieldDiscriminatorNode("discriminator", 0)],
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain(
      "getU64Encoder().encode(BigInt.from(3))",
    );
  });

  it("renders size and constant discriminator conditions", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [
        instructionNode({
          name: "bySize",
          accounts: [],
          arguments: [],
          discriminators: [sizeDiscriminatorNode(8)],
        }),
        instructionNode({
          name: "byConstant",
          accounts: [],
          arguments: [],
          discriminators: [
            constantDiscriminatorNode(
              constantValueNode(numberTypeNode("u32"), numberValueNode(42)),
              0,
            ),
          ],
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain("data.length == 8");
    expect(frag.content).toContain("containsBytes(data, getU32Encoder().encode(42), 0)");
  });

  it("renders boolean, string, and bytes value fragments", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [
        instructionNode({
          name: "byBool",
          accounts: [],
          arguments: [],
          discriminators: [
            constantDiscriminatorNode(
              constantValueNode(booleanTypeNode(), booleanValueNode(true)),
              0,
            ),
          ],
        }),
        instructionNode({
          name: "byString",
          accounts: [],
          arguments: [],
          discriminators: [
            constantDiscriminatorNode(
              constantValueNode(stringTypeNode("utf8"), stringValueNode("hi")),
              0,
            ),
          ],
        }),
        instructionNode({
          name: "byBytes",
          accounts: [],
          arguments: [],
          discriminators: [
            constantDiscriminatorNode(
              constantValueNode(bytesTypeNode(), bytesValueNode("base16", "0x0102")),
              0,
            ),
          ],
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain("encode(true)");
    expect(frag.content).toContain("encode('hi')");
    expect(frag.content).toContain("Uint8List.fromList([1, 2])");
  });

  it("skips helpers when a discriminator value is unsupported", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [
        instructionNode({
          name: "byMap",
          accounts: [],
          arguments: [],
          discriminators: [
            constantDiscriminatorNode(
              constantValueNode(
                mapTypeNode(numberTypeNode("u8"), numberTypeNode("u8")),
                mapValueNode([]),
              ),
              0,
            ),
          ],
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).not.toContain("identifyMyProgramInstruction");
    expect(frag.content).not.toContain("parseMyProgramInstruction");
  });

  it("skips field discriminators when the instruction has no arguments", () => {
    // Construct the instruction without the `instructionNode` factory so
    // `arguments` stays undefined, exercising the `?? []` fallback.
    const rawInstruction = {
      kind: "instructionNode",
      name: "byField",
      accounts: [],
      discriminators: [fieldDiscriminatorNode("missing", 0)],
    };
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [rawInstruction],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).not.toContain("identifyMyProgramInstruction");
    expect(frag.content).not.toContain("parseMyProgramInstruction");
  });

  it("skips field discriminators with unsupported default values", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [
        instructionNode({
          name: "byField",
          accounts: [],
          arguments: [
            instructionArgumentNode({
              name: "discriminator",
              type: mapTypeNode(numberTypeNode("u8"), numberTypeNode("u8")),
              defaultValue: mapValueNode([]),
            }),
          ],
          discriminators: [fieldDiscriminatorNode("discriminator", 0)],
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).not.toContain("identifyMyProgramInstruction");
    expect(frag.content).not.toContain("parseMyProgramInstruction");
  });

  it("renders an empty bytes list when the hex data has no pairs", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [
        instructionNode({
          name: "byEmptyBytes",
          accounts: [],
          arguments: [],
          discriminators: [
            constantDiscriminatorNode(
              constantValueNode(bytesTypeNode(), bytesValueNode("base16", "")),
              0,
            ),
          ],
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain("Uint8List.fromList([])");
  });

  it("renders an int number value fragment", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [
        instructionNode({
          name: "byInt",
          accounts: [],
          arguments: [
            instructionArgumentNode({
              name: "discriminator",
              type: numberTypeNode("u8"),
              defaultValue: numberValueNode(7),
            }),
          ],
          discriminators: [fieldDiscriminatorNode("discriminator", 0)],
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain("getU8Encoder().encode(7)");
  });

  it("does not generate instruction helpers without discriminators", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      instructions: [
        instructionNode({
          name: "initialize",
          accounts: [],
          arguments: [],
        }),
      ],
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).not.toContain("identifyMyProgramInstruction");
    expect(frag.content).not.toContain("parseMyProgramInstruction");
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

  it("uses export for well-known address with matching name", () => {
    // System program — well-known name matches generated name
    const node = programNode({
      name: "system",
      publicKey: "11111111111111111111111111111111",
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain("export 'package:solana_kit_addresses/solana_kit_addresses.dart' show systemProgramAddress");
    expect(frag.content).not.toContain("const systemProgramAddress = Address(");
    expect(frag.imports.modules.has("solanaAddresses")).toBe(false); // export, not import
  });

  it("uses const alias for well-known address with different name", () => {
    // Staking program — generated name 'stakingProgramAddress' differs from canonical 'stakeProgramAddress'
    const node = programNode({
      name: "staking",
      publicKey: "Stake11111111111111111111111111111111111111",
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain("const stakingProgramAddress = stakeProgramAddress");
    expect(frag.content).toContain("/// The address of the Staking program.");
    expect(frag.imports.modules.has("solanaAddresses")).toBe(true);
    expect(frag.imports.modules.has("Address")).toBe(false); // should not import Address since using canonical name
  });

  it("uses Address for unknown address", () => {
    // Unknown program — falls back to Address('...')
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
    });
    const frag = getProgramPageFragment(node, createScope());

    expect(frag.content).toContain("const myProgramProgramAddress = Address('");
    expect(frag.content).toContain("MyProgram1111111111111111111111111111111111");
    expect(frag.imports.modules.has("solanaAddresses")).toBe(true);
  });
});
