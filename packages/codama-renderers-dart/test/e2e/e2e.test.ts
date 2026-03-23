import { existsSync, mkdirSync, readFileSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { visit } from "@codama/visitors-core";
import {
  rootNode,
  programNode,
  accountNode,
  instructionNode,
  instructionAccountNode,
  instructionArgumentNode,
  definedTypeNode,
  errorNode,
  pdaNode,
  structTypeNode,
  structFieldTypeNode,
  numberTypeNode,
  publicKeyTypeNode,
  booleanTypeNode,
  enumTypeNode,
  enumEmptyVariantTypeNode,
  constantPdaSeedNodeFromString,
  variablePdaSeedNode,
  constantDiscriminatorNode,
  fieldDiscriminatorNode,
  constantValueNodeFromBytes,
  numberValueNode,
} from "@codama/nodes";

import { renderVisitor } from "../../src/visitors/renderVisitor.js";
import { getRenderMapVisitor } from "../../src/visitors/getRenderMapVisitor.js";

/**
 * Build a sample Codama IDL for a "counter" program using @codama/nodes constructors.
 */
function buildCounterIdl() {
  return rootNode(
    programNode({
      name: "counter",
      publicKey: "CountR1Program111111111111111111111111111111",
      accounts: [
        // Account 1: simple struct (CounterState)
        accountNode({
          name: "counterState",
          data: structTypeNode([
            structFieldTypeNode({ name: "authority", type: publicKeyTypeNode() }),
            structFieldTypeNode({ name: "count", type: numberTypeNode("u64") }),
            structFieldTypeNode({ name: "isInitialized", type: booleanTypeNode() }),
          ]),
        }),
        // Account 2: struct with discriminator (CounterMetadata)
        accountNode({
          name: "counterMetadata",
          data: structTypeNode([
            structFieldTypeNode({ name: "discriminator", type: numberTypeNode("u8") }),
            structFieldTypeNode({ name: "name", type: numberTypeNode("u32") }),
            structFieldTypeNode({ name: "bump", type: numberTypeNode("u8") }),
          ]),
          discriminators: [
            constantDiscriminatorNode(
              constantValueNodeFromBytes("base16", "aabbccdd"),
            ),
          ],
        }),
      ],
      instructions: [
        // Instruction 1: with accounts and args (initialize)
        instructionNode({
          name: "initialize",
          accounts: [
            instructionAccountNode({
              name: "counterAccount",
              isSigner: false,
              isWritable: true,
            }),
            instructionAccountNode({
              name: "authority",
              isSigner: true,
              isWritable: false,
            }),
            instructionAccountNode({
              name: "systemProgram",
              isSigner: false,
              isWritable: false,
            }),
          ],
          arguments: [
            instructionArgumentNode({
              name: "discriminator",
              type: numberTypeNode("u8"),
              defaultValue: numberValueNode(0),
            }),
            instructionArgumentNode({
              name: "initialValue",
              type: numberTypeNode("u64"),
            }),
          ],
          discriminators: [
            fieldDiscriminatorNode("discriminator", 0),
          ],
        }),
        // Instruction 2: simple (increment)
        instructionNode({
          name: "increment",
          accounts: [
            instructionAccountNode({
              name: "counterAccount",
              isSigner: false,
              isWritable: true,
            }),
            instructionAccountNode({
              name: "authority",
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
      definedTypes: [
        // Type 1: struct type (CounterConfig)
        definedTypeNode({
          name: "counterConfig",
          type: structTypeNode([
            structFieldTypeNode({ name: "maxCount", type: numberTypeNode("u64") }),
            structFieldTypeNode({ name: "isActive", type: booleanTypeNode() }),
          ]),
        }),
        // Type 2: scalar enum (CounterStatus)
        definedTypeNode({
          name: "counterStatus",
          type: enumTypeNode([
            enumEmptyVariantTypeNode("active"),
            enumEmptyVariantTypeNode("paused"),
            enumEmptyVariantTypeNode("closed"),
          ]),
        }),
      ],
      errors: [
        errorNode({
          name: "invalidAuthority",
          code: 6000,
          message: "The provided authority is invalid.",
        }),
      ],
      pdas: [
        pdaNode({
          name: "counterPda",
          seeds: [
            constantPdaSeedNodeFromString("utf8", "counter"),
            variablePdaSeedNode("authority", publicKeyTypeNode()),
          ],
        }),
      ],
    }),
  );
}

describe("E2E: renderVisitor", () => {
  let outputDir: string;

  beforeEach(() => {
    outputDir = join(tmpdir(), `codama-dart-e2e-${Date.now()}-${Math.random().toString(36).slice(2)}`);
    mkdirSync(outputDir, { recursive: true });
  });

  afterEach(() => {
    if (existsSync(outputDir)) {
      rmSync(outputDir, { recursive: true, force: true });
    }
  });

  it("should generate the expected directory structure", () => {
    const idl = buildCounterIdl();
    visit(idl, renderVisitor(outputDir, { formatCode: false }));

    // Root barrel file
    expect(existsSync(join(outputDir, "counter.dart"))).toBe(true);

    // Category barrel files
    expect(existsSync(join(outputDir, "accounts/accounts.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "instructions/instructions.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "types/types.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "errors/errors.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "programs/programs.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "pdas/pdas.dart"))).toBe(true);

    // Individual files
    expect(existsSync(join(outputDir, "accounts/counter_state.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "accounts/counter_metadata.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "instructions/initialize.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "instructions/increment.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "types/counter_config.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "types/counter_status.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "errors/counter.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "programs/counter.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "pdas/counter_pda.dart"))).toBe(true);
  });

  it("should generate proper root barrel exports", () => {
    const idl = buildCounterIdl();
    visit(idl, renderVisitor(outputDir, { formatCode: false }));

    const content = readFileSync(join(outputDir, "counter.dart"), "utf-8");

    expect(content).toContain("export 'accounts/accounts.dart';");
    expect(content).toContain("export 'errors/errors.dart';");
    expect(content).toContain("export 'instructions/instructions.dart';");
    expect(content).toContain("export 'programs/programs.dart';");
    expect(content).toContain("export 'types/types.dart';");
    expect(content).toContain("export 'pdas/pdas.dart';");
  });

  it("should generate proper category barrel exports", () => {
    const idl = buildCounterIdl();
    visit(idl, renderVisitor(outputDir, { formatCode: false }));

    const accountsBarrel = readFileSync(join(outputDir, "accounts/accounts.dart"), "utf-8");
    expect(accountsBarrel).toContain("export 'counter_state.dart';");
    expect(accountsBarrel).toContain("export 'counter_metadata.dart';");

    const instructionsBarrel = readFileSync(join(outputDir, "instructions/instructions.dart"), "utf-8");
    expect(instructionsBarrel).toContain("export 'initialize.dart';");
    expect(instructionsBarrel).toContain("export 'increment.dart';");

    const typesBarrel = readFileSync(join(outputDir, "types/types.dart"), "utf-8");
    expect(typesBarrel).toContain("export 'counter_config.dart';");
    expect(typesBarrel).toContain("export 'counter_status.dart';");
  });

  it("should generate correct account code for CounterState", () => {
    const idl = buildCounterIdl();
    visit(idl, renderVisitor(outputDir, { formatCode: false }));

    const content = readFileSync(join(outputDir, "accounts/counter_state.dart"), "utf-8");

    // Header comment
    expect(content).toContain("// Auto-generated. Do not edit.");
    expect(content).toContain("// ignore_for_file: type=lint");

    // Imports
    expect(content).toContain("import 'dart:typed_data';");
    expect(content).toContain("import 'package:meta/meta.dart';");
    expect(content).toContain("import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';");
    expect(content).toContain("import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';");

    // Class declaration
    expect(content).toContain("@immutable");
    expect(content).toContain("class CounterState {");
    expect(content).toContain("const CounterState({");

    // Fields
    expect(content).toContain("final Address authority;");
    expect(content).toContain("final BigInt count;");
    expect(content).toContain("final bool isInitialized;");

    // Constructor params
    expect(content).toContain("required this.authority,");
    expect(content).toContain("required this.count,");
    expect(content).toContain("required this.isInitialized,");

    // Encoder
    expect(content).toContain("Encoder<CounterState> getCounterStateEncoder()");
    expect(content).toContain("getStructEncoder");
    expect(content).toContain("getAddressEncoder()");

    // Decoder
    expect(content).toContain("Decoder<CounterState> getCounterStateDecoder()");
    expect(content).toContain("getStructDecoder");

    // Codec
    expect(content).toContain("Codec<CounterState, CounterState> getCounterStateCodec()");
    expect(content).toContain("combineCodec(getCounterStateEncoder(), getCounterStateDecoder())");

    // Account decode function
    expect(content).toContain("Account<CounterState> decodeCounterState(EncodedAccount encodedAccount)");
    expect(content).toContain("decodeAccount(encodedAccount, getCounterStateDecoder())");

    // Equality operators
    expect(content).toContain("bool operator ==(Object other)");
    expect(content).toContain("int get hashCode");
    expect(content).toContain("String toString()");
  });

  it("should generate discriminator constants for CounterMetadata", () => {
    const idl = buildCounterIdl();
    visit(idl, renderVisitor(outputDir, { formatCode: false }));

    const content = readFileSync(join(outputDir, "accounts/counter_metadata.dart"), "utf-8");

    // Should have discriminator constant
    expect(content).toContain("counterMetadataDiscriminator");
    expect(content).toContain("Uint8List.fromList(");
    expect(content).toContain("0xaa");
    expect(content).toContain("0xbb");
    expect(content).toContain("0xcc");
    expect(content).toContain("0xdd");
  });

  it("should generate correct instruction code for Initialize", () => {
    const idl = buildCounterIdl();
    visit(idl, renderVisitor(outputDir, { formatCode: false }));

    const content = readFileSync(join(outputDir, "instructions/initialize.dart"), "utf-8");

    // Imports
    expect(content).toContain("import 'package:solana_kit_addresses/solana_kit_addresses.dart';");
    expect(content).toContain("import 'package:solana_kit_instructions/solana_kit_instructions.dart';");

    // Instruction data class
    expect(content).toContain("class InitializeInstructionData {");
    expect(content).toContain("final int discriminator;");
    expect(content).toContain("final BigInt initialValue;");

    // Field discriminator with default value
    expect(content).toContain("this.discriminator = 0,");

    // Encoder/Decoder/Codec
    expect(content).toContain("getInitializeInstructionDataEncoder()");
    expect(content).toContain("getInitializeInstructionDataDecoder()");
    expect(content).toContain("getInitializeInstructionDataCodec()");

    // Instruction builder function
    expect(content).toContain("Instruction getInitializeInstruction({");
    expect(content).toContain("required Address programAddress,");

    // Account metas with correct roles
    expect(content).toContain("AccountMeta(address: counterAccount, role: AccountRole.writable)");
    expect(content).toContain("AccountMeta(address: authority, role: AccountRole.readonlySigner)");
    expect(content).toContain("AccountMeta(address: systemProgram, role: AccountRole.readonly)");

    // Parse function
    expect(content).toContain("InitializeInstructionData parseInitializeInstruction(Instruction instruction)");

    // Discriminator documentation
    expect(content).toContain("discriminator field name");

    // Account parameters should use proper Address type
    expect(content).toContain("required Address counterAccount,");
    expect(content).toContain("required Address authority,");
    expect(content).toContain("required Address systemProgram,");

    // Should NOT contain [object Object] from Fragment interpolation bugs
    expect(content).not.toContain("[object Object]");
  });

  it("should generate correct instruction code for Increment (simple)", () => {
    const idl = buildCounterIdl();
    visit(idl, renderVisitor(outputDir, { formatCode: false }));

    const content = readFileSync(join(outputDir, "instructions/increment.dart"), "utf-8");

    // Instruction data class
    expect(content).toContain("class IncrementInstructionData {");
    expect(content).toContain("final BigInt amount;");

    // Instruction builder
    expect(content).toContain("Instruction getIncrementInstruction({");
    expect(content).toContain("required Address programAddress,");

    // Account metas: authority is signer+writable
    expect(content).toContain("AccountMeta(address: counterAccount, role: AccountRole.writable)");
    expect(content).toContain("AccountMeta(address: authority, role: AccountRole.writableSigner)");

    // Parse function
    expect(content).toContain("IncrementInstructionData parseIncrementInstruction(Instruction instruction)");

    // Encoder/Decoder
    expect(content).toContain("getIncrementInstructionDataEncoder()");
    expect(content).toContain("getIncrementInstructionDataDecoder()");
  });

  it("should generate correct struct defined type for CounterConfig", () => {
    const idl = buildCounterIdl();
    visit(idl, renderVisitor(outputDir, { formatCode: false }));

    const content = readFileSync(join(outputDir, "types/counter_config.dart"), "utf-8");

    // Class
    expect(content).toContain("@immutable");
    expect(content).toContain("class CounterConfig {");
    expect(content).toContain("final BigInt maxCount;");
    expect(content).toContain("final bool isActive;");

    // Codec functions
    expect(content).toContain("Encoder<CounterConfig> getCounterConfigEncoder()");
    expect(content).toContain("Decoder<CounterConfig> getCounterConfigDecoder()");
    expect(content).toContain("Codec<CounterConfig, CounterConfig> getCounterConfigCodec()");
  });

  it("should generate correct scalar enum for CounterStatus", () => {
    const idl = buildCounterIdl();
    visit(idl, renderVisitor(outputDir, { formatCode: false }));

    const content = readFileSync(join(outputDir, "types/counter_status.dart"), "utf-8");

    // Enum declaration
    expect(content).toContain("enum CounterStatus {");
    expect(content).toContain("active,");
    expect(content).toContain("paused,");
    expect(content).toContain("closed,");

    // Codec functions using transformEncoder/transformDecoder with U8
    expect(content).toContain("Encoder<CounterStatus> getCounterStatusEncoder()");
    expect(content).toContain("Decoder<CounterStatus> getCounterStatusDecoder()");
    expect(content).toContain("Codec<CounterStatus, CounterStatus> getCounterStatusCodec()");
    expect(content).toContain("transformEncoder");
    expect(content).toContain("getU8Encoder()");
    expect(content).toContain("value.index");
    expect(content).toContain("CounterStatus.values[");
  });

  it("should generate correct error code page", () => {
    const idl = buildCounterIdl();
    visit(idl, renderVisitor(outputDir, { formatCode: false }));

    const content = readFileSync(join(outputDir, "errors/counter.dart"), "utf-8");

    // Error code constant
    expect(content).toContain("counterErrorInvalidAuthority");
    expect(content).toContain("0x1770"); // 6000 in hex
    expect(content).toContain("6000");

    // Error message map
    expect(content).toContain("The provided authority is invalid.");

    // Error message function
    expect(content).toContain("getCounterErrorMessage");

    // Error check function
    expect(content).toContain("isCounterError");
  });

  it("should generate correct program page", () => {
    const idl = buildCounterIdl();
    visit(idl, renderVisitor(outputDir, { formatCode: false }));

    const content = readFileSync(join(outputDir, "programs/counter.dart"), "utf-8");

    // Program address constant
    expect(content).toContain("counterProgramAddress");
    expect(content).toContain("Address('CountR1Program111111111111111111111111111111')");

    // Account enum
    expect(content).toContain("enum CounterAccount {");
    expect(content).toContain("counterState,");
    expect(content).toContain("counterMetadata,");

    // Instruction enum
    expect(content).toContain("enum CounterInstruction {");
    expect(content).toContain("initialize,");
    expect(content).toContain("increment,");
  });

  it("should generate correct PDA page", () => {
    const idl = buildCounterIdl();
    visit(idl, renderVisitor(outputDir, { formatCode: false }));

    const content = readFileSync(join(outputDir, "pdas/counter_pda.dart"), "utf-8");

    // Seeds class
    expect(content).toContain("class CounterPdaSeeds {");
    expect(content).toContain("final Address authority;");
    expect(content).toContain("required this.authority,");

    // Finder function
    expect(content).toContain("findCounterPdaPda");

    // Constant seed
    expect(content).toContain("'counter'");

    // Variable seed
    expect(content).toContain("seeds.authority");

    // Seeds parameter
    expect(content).toContain("seeds,");

    // Generated PDA derivation call
    expect(content).toContain("return getProgramDerivedAddress(");
    expect(content).toContain("final seeds = <Object>[");
    expect(content).not.toContain("UnimplementedError");

    // Should NOT contain [object Object] from Fragment interpolation bugs
    expect(content).not.toContain("[object Object]");

    // PDA-specific imports
    expect(content).toContain("import 'package:solana_kit_addresses/solana_kit_addresses.dart';");
    expect(content).toContain("import 'package:meta/meta.dart';");
  });

  it("should delete output folder before rendering by default", () => {
    const idl = buildCounterIdl();

    // First render
    visit(idl, renderVisitor(outputDir, { formatCode: false }));
    expect(existsSync(join(outputDir, "counter.dart"))).toBe(true);

    // Second render should still succeed (folder is deleted and recreated)
    visit(idl, renderVisitor(outputDir, { formatCode: false }));
    expect(existsSync(join(outputDir, "counter.dart"))).toBe(true);
  });

  it("should preserve existing files when deleteFolderBeforeRendering is false", () => {
    const idl = buildCounterIdl();

    // Create a marker file
    const markerPath = join(outputDir, "marker.txt");
    const { writeFileSync } = require("node:fs");
    writeFileSync(markerPath, "keep me", "utf-8");

    visit(idl, renderVisitor(outputDir, {
      formatCode: false,
      deleteFolderBeforeRendering: false,
    }));

    // Marker should still exist
    expect(existsSync(markerPath)).toBe(true);
    // Generated files should also exist
    expect(existsSync(join(outputDir, "counter.dart"))).toBe(true);
  });
});

describe("E2E: getRenderMapVisitor", () => {
  it("should produce a render map with expected file keys", () => {
    const idl = buildCounterIdl();
    const renderMap = visit(idl, getRenderMapVisitor());

    const keys = [...renderMap.keys()].sort();

    expect(keys).toContain("accounts/accounts.dart");
    expect(keys).toContain("accounts/counter_state.dart");
    expect(keys).toContain("accounts/counter_metadata.dart");
    expect(keys).toContain("instructions/instructions.dart");
    expect(keys).toContain("instructions/initialize.dart");
    expect(keys).toContain("instructions/increment.dart");
    expect(keys).toContain("types/types.dart");
    expect(keys).toContain("types/counter_config.dart");
    expect(keys).toContain("types/counter_status.dart");
    expect(keys).toContain("errors/errors.dart");
    expect(keys).toContain("errors/counter.dart");
    expect(keys).toContain("programs/programs.dart");
    expect(keys).toContain("programs/counter.dart");
    expect(keys).toContain("pdas/pdas.dart");
    expect(keys).toContain("pdas/counter_pda.dart");
    expect(keys).toContain("counter.dart");
  });

  it("should produce fragments with non-empty content", () => {
    const idl = buildCounterIdl();
    const renderMap = visit(idl, getRenderMapVisitor());

    for (const [key, fragment] of renderMap.entries()) {
      expect(fragment.content, `Fragment for ${key} should have content`).toBeTruthy();
    }
  });

  it("should produce fragments with DartImportMap instances", () => {
    const idl = buildCounterIdl();
    const renderMap = visit(idl, getRenderMapVisitor());

    // Account fragments should need imports
    const counterStateFragment = renderMap.get("accounts/counter_state.dart");
    expect(counterStateFragment).toBeDefined();
    expect(counterStateFragment!.imports).toBeDefined();
    expect(counterStateFragment!.imports.isEmpty).toBe(false);
  });
});
