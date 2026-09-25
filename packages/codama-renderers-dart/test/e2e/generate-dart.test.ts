import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, readdirSync, rmSync, statSync } from "node:fs";
import { join, resolve } from "node:path";
import { describe, it, expect, beforeAll } from "vitest";
import { visit } from "@codama/visitors-core";
import {
  accountNode,
  arrayTypeNode,
  constantDiscriminatorNode,
  constantValueNode,
  definedTypeNode,
  enumEmptyVariantTypeNode,
  enumTypeNode,
  fieldDiscriminatorNode,
  fixedSizeTypeNode,
  instructionAccountNode,
  instructionArgumentNode,
  instructionNode,
  numberTypeNode,
  numberValueNode,
  programNode,
  remainderCountNode,
  rootNode,
  sizeDiscriminatorNode,
  stringTypeNode,
  structFieldTypeNode,
  structTypeNode,
} from "@codama/nodes";
import { rootNodeFromAnchor } from "@codama/nodes-from-anchor";

import { renderVisitor } from "../../src/visitors/renderVisitor.js";

import tokenVaultIdl from "../fixtures/token_vault.json";
import stakingIdl from "../fixtures/staking.json";

const TEST_GENERATED_DIR = resolve(__dirname, "../../test-generated");
const TOKEN_VAULT_DIR = join(TEST_GENERATED_DIR, "lib/src/token_vault");
const STAKING_DIR = join(TEST_GENERATED_DIR, "lib/src/staking");
const FIXED_CAPACITY_DIR = join(
  TEST_GENERATED_DIR,
  "lib/src/fixed_capacity",
);
const WIDE_ENUMS_DIR = join(TEST_GENERATED_DIR, "lib/src/wide_enums");
const SECURITY_DIR = join(TEST_GENERATED_DIR, "lib/src/security_fixture");

function buildSecurityFixture() {
  const u8 = numberTypeNode("u8");
  const u16 = numberTypeNode("u16");

  return rootNode(
    programNode({
      name: "securityFixture",
      publicKey: "11111111111111111111111111111111",
      accounts: [
        accountNode({
          name: "secureState",
          size: 3,
          data: structTypeNode([
            structFieldTypeNode({
              name: "discriminator",
              type: u8,
              defaultValue: numberValueNode(7),
              defaultValueStrategy: "omitted",
            }),
            structFieldTypeNode({ name: "value", type: u16 }),
          ]),
          discriminators: [
            fieldDiscriminatorNode("discriminator", 0),
            constantDiscriminatorNode(
              constantValueNode(u8, numberValueNode(7)),
              0,
            ),
            sizeDiscriminatorNode(3),
          ],
        }),
        accountNode({
          name: "exactState",
          data: structTypeNode([
            structFieldTypeNode({ name: "value", type: u16 }),
          ]),
        }),
      ],
      instructions: [
        instructionNode({
          name: "secureAction",
          optionalAccountStrategy: "programId",
          accounts: [
            instructionAccountNode({
              name: "before",
              isSigner: false,
              isWritable: false,
            }),
            instructionAccountNode({
              name: "optionalMiddle",
              isSigner: false,
              isWritable: true,
              isOptional: true,
            }),
            instructionAccountNode({
              name: "after",
              isSigner: true,
              isWritable: false,
            }),
          ],
          arguments: [
            instructionArgumentNode({
              name: "discriminator",
              type: u8,
              defaultValue: numberValueNode(9),
              defaultValueStrategy: "omitted",
            }),
            instructionArgumentNode({ name: "amount", type: u16 }),
          ],
          discriminators: [
            fieldDiscriminatorNode("discriminator", 0),
            constantDiscriminatorNode(
              constantValueNode(u8, numberValueNode(9)),
              0,
            ),
            sizeDiscriminatorNode(3),
          ],
        }),
        instructionNode({
          name: "legacyOptionalAction",
          optionalAccountStrategy: "omitted",
          accounts: [
            instructionAccountNode({
              name: "before",
              isSigner: false,
              isWritable: false,
            }),
            instructionAccountNode({
              name: "optionalMiddle",
              isSigner: false,
              isWritable: true,
              isOptional: true,
            }),
            instructionAccountNode({
              name: "after",
              isSigner: true,
              isWritable: false,
            }),
          ],
          arguments: [],
        }),
        instructionNode({
          name: "exactAction",
          accounts: [],
          arguments: [
            instructionArgumentNode({ name: "amount", type: u16 }),
          ],
        }),
      ],
    }),
  );
}

function buildWideEnumsIdl() {
  const definedTypes = (["u8", "u16", "u32", "u64"] as const).map(
    (format) =>
      definedTypeNode({
        name: `status${format.toUpperCase()}`,
        type: enumTypeNode(
          [
            enumEmptyVariantTypeNode("inactive"),
            enumEmptyVariantTypeNode("active"),
          ],
          { size: numberTypeNode(format) },
        ),
      }),
  );

  return rootNode(
    programNode({
      name: "wideEnums",
      publicKey: "11111111111111111111111111111111",
      definedTypes,
    }),
  );
}


/**
 * Recursively collect all file paths under a directory.
 */
function collectFiles(dir: string, prefix = ""): string[] {
  const files: string[] = [];
  if (!existsSync(dir)) return files;
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    const relative = prefix ? `${prefix}/${entry}` : entry;
    if (statSync(full).isDirectory()) {
      files.push(...collectFiles(full, relative));
    } else {
      files.push(relative);
    }
  }
  return files.sort();
}

describe("Generate Dart code and validate", () => {
  beforeAll(() => {
    // Generate token_vault code
    const tvRoot = rootNodeFromAnchor(tokenVaultIdl);
    visit(
      tvRoot,
      renderVisitor(TOKEN_VAULT_DIR, {
        formatCode: true,
        deleteFolderBeforeRendering: true,
      }),
    );

    // Generate staking code
    const stakingRoot = rootNodeFromAnchor(stakingIdl);
    visit(
      stakingRoot,
      renderVisitor(STAKING_DIR, {
        formatCode: true,
        deleteFolderBeforeRendering: true,
      }),
    );

    const fixedCapacityRoot = rootNode(
      programNode({
        name: "fixedCapacity",
        publicKey: "11111111111111111111111111111111",
        definedTypes: [
          definedTypeNode({
            name: "fixedName",
            type: fixedSizeTypeNode(stringTypeNode("utf8"), 4),
          }),
          definedTypeNode({
            name: "fixedValues",
            type: fixedSizeTypeNode(
              arrayTypeNode(numberTypeNode("u8"), remainderCountNode()),
              4,
            ),
          }),
        ],
      }),
    );
    visit(
      fixedCapacityRoot,
      renderVisitor(FIXED_CAPACITY_DIR, {
        formatCode: false,
        deleteFolderBeforeRendering: true,
      }),
    );

    visit(
      buildWideEnumsIdl(),
      renderVisitor(WIDE_ENUMS_DIR, {
        formatCode: false,
        deleteFolderBeforeRendering: true,
      }),
    );

    visit(
      buildSecurityFixture(),
      renderVisitor(SECURITY_DIR, {
        formatCode: false,
        deleteFolderBeforeRendering: true,
      }),
    );

    // The workspace includes Flutter examples, so its shared resolution must
    // use Flutter's pub wrapper even though this generated package is pure Dart.
    execFileSync("flutter", ["pub", "get"], {
      cwd: TEST_GENERATED_DIR,
      stdio: "pipe",
      timeout: 120_000,
    });
  }, 180_000);

  it("should generate token_vault files", () => {
    const files = collectFiles(TOKEN_VAULT_DIR);
    expect(files.length).toBeGreaterThan(0);
    expect(files).toContain("token_vault.dart");
    expect(files).toContain("accounts/vault.dart");
    expect(files).toContain("accounts/deposit_record.dart");
    expect(files).toContain("instructions/initialize_vault.dart");
    expect(files).toContain("instructions/deposit.dart");
    expect(files).toContain("instructions/withdraw.dart");
    expect(files).toContain("instructions/update_vault_status.dart");
    expect(files).toContain("types/vault_status.dart");
    expect(files).toContain("types/vault_config.dart");
    expect(files).toContain("errors/token_vault.dart");
    expect(files).toContain("programs/token_vault.dart");
  });

  it("should generate staking files", () => {
    const files = collectFiles(STAKING_DIR);
    expect(files.length).toBeGreaterThan(0);
    expect(files).toContain("staking.dart");
    expect(files).toContain("accounts/stake_pool.dart");
    expect(files).toContain("accounts/stake_account.dart");
    expect(files).toContain("instructions/initialize_pool.dart");
    expect(files).toContain("instructions/stake.dart");
    expect(files).toContain("instructions/unstake.dart");
    expect(files).toContain("instructions/claim_rewards.dart");
    expect(files).toContain("types/pool_status.dart");
    expect(files).toContain("types/stake_info.dart");
    expect(files).toContain("errors/staking.dart");
    expect(files).toContain("programs/staking.dart");
  });

  it("should generate non-truncating fixed-capacity codecs", () => {
    const fixedName = readFileSync(
      join(FIXED_CAPACITY_DIR, "types/fixed_name.dart"),
      "utf-8",
    );
    const fixedValues = readFileSync(
      join(FIXED_CAPACITY_DIR, "types/fixed_values.dart"),
      "utf-8",
    );

    expect(fixedName).toContain("allowTruncation: false");
    expect(fixedValues).toContain("allowTruncation: false");
  });

  it("should generate scalar enums for every supported unsigned width", () => {
    const files = collectFiles(WIDE_ENUMS_DIR);

    expect(files).toContain("types/status_u8.dart");
    expect(files).toContain("types/status_u16.dart");
    expect(files).toContain("types/status_u32.dart");
    expect(files).toContain("types/status_u64.dart");
  });

  it("should generate discriminator and optional-account fixtures", () => {
    const files = collectFiles(SECURITY_DIR);
    expect(files).toContain("accounts/secure_state.dart");
    expect(files).toContain("accounts/exact_state.dart");
    expect(files).toContain("instructions/secure_action.dart");
    expect(files).toContain("instructions/legacy_optional_action.dart");
    expect(files).toContain("instructions/exact_action.dart");
  });

  it("should generate valid Dart syntax in error page files", () => {
    // Error pages are the cleanest generated code — pure constants and functions
    const tvErrors = readFileSync(
      join(TOKEN_VAULT_DIR, "errors/token_vault.dart"),
      "utf-8",
    );
    expect(tvErrors).toContain("const int tokenVaultErrorInvalidAuthority");
    expect(tvErrors).toContain("String? getTokenVaultErrorMessage(int code)");
    expect(tvErrors).toContain("bool isTokenVaultError(int code)");
    expect(tvErrors).not.toContain("[object Object]");

    const stakingErrors = readFileSync(
      join(STAKING_DIR, "errors/staking.dart"),
      "utf-8",
    );
    expect(stakingErrors).toContain("const int stakingErrorPoolNotActive");
    expect(stakingErrors).toContain("String? getStakingErrorMessage(int code)");
    expect(stakingErrors).not.toContain("[object Object]");
  });

  it("should generate valid Dart syntax in program page files", () => {
    const tvProgram = readFileSync(
      join(TOKEN_VAULT_DIR, "programs/token_vault.dart"),
      "utf-8",
    );
    expect(tvProgram).toContain("const tokenVaultProgramAddress");
    expect(tvProgram).toContain("enum TokenVaultAccount {");
    expect(tvProgram).toContain("enum TokenVaultInstruction {");
    expect(tvProgram).not.toContain("[object Object]");

    const stakingProgram = readFileSync(
      join(STAKING_DIR, "programs/staking.dart"),
      "utf-8",
    );
    expect(stakingProgram).toContain("const stakingProgramAddress");
    expect(stakingProgram).toContain("enum StakingAccount {");
    expect(stakingProgram).toContain("enum StakingInstruction {");
    expect(stakingProgram).not.toContain("[object Object]");
  });

  it("should generate valid Dart syntax in barrel export files", () => {
    const tvBarrel = readFileSync(
      join(TOKEN_VAULT_DIR, "token_vault.dart"),
      "utf-8",
    );
    expect(tvBarrel).toContain("export '");
    expect(tvBarrel).not.toContain("[object Object]");

    const stakingBarrel = readFileSync(
      join(STAKING_DIR, "staking.dart"),
      "utf-8",
    );
    expect(stakingBarrel).toContain("export '");
    expect(stakingBarrel).not.toContain("[object Object]");
  });

  it("should generate enum types with codec functions", () => {
    const vaultStatus = readFileSync(
      join(TOKEN_VAULT_DIR, "types/vault_status.dart"),
      "utf-8",
    );
    expect(vaultStatus).toContain("enum VaultStatus {");
    expect(vaultStatus).toContain("getVaultStatusEncoder()");
    expect(vaultStatus).toContain("getVaultStatusDecoder()");
    expect(vaultStatus).toContain("getVaultStatusCodec()");

    const poolStatus = readFileSync(
      join(STAKING_DIR, "types/pool_status.dart"),
      "utf-8",
    );
    expect(poolStatus).toContain("enum PoolStatus {");
    expect(poolStatus).toContain("getPoolStatusEncoder()");
    expect(poolStatus).toContain("getPoolStatusDecoder()");
    expect(poolStatus).toContain("getPoolStatusCodec()");
  });

  it("should generate struct types with fields and codecs", () => {
    const vaultConfig = readFileSync(
      join(TOKEN_VAULT_DIR, "types/vault_config.dart"),
      "utf-8",
    );
    expect(vaultConfig).toContain("class VaultConfig {");
    expect(vaultConfig).toContain("final BigInt maxCapacity;");
    expect(vaultConfig).toContain("final BigInt minDeposit;");
    expect(vaultConfig).toContain("final int feeRate;");
    expect(vaultConfig).toContain("final bool isActive;");
    expect(vaultConfig).toContain("getVaultConfigEncoder()");
    expect(vaultConfig).toContain("getVaultConfigDecoder()");

    const stakeInfo = readFileSync(
      join(STAKING_DIR, "types/stake_info.dart"),
      "utf-8",
    );
    expect(stakeInfo).toContain("class StakeInfo {");
    expect(stakeInfo).toContain("final BigInt amount;");
    expect(stakeInfo).toContain("final BigInt startTime;");
    expect(stakeInfo).toContain("endTime");
    expect(stakeInfo).toContain("final bool isLocked;");
  });

  it("formats, analyzes, and tests the complete generated Dart package", { timeout: 180_000 }, () => {
    execFileSync("dart", ["format", "--output=none", "."], {
      cwd: TEST_GENERATED_DIR,
      stdio: "pipe",
      timeout: 120_000,
    });

    execFileSync("dart", ["analyze", "--fatal-infos"], {
      cwd: TEST_GENERATED_DIR,
      stdio: "pipe",
      timeout: 120_000,
    });

    execFileSync("dart", ["test"], {
      cwd: TEST_GENERATED_DIR,
      stdio: "pipe",
      timeout: 120_000,
    });
  });
});
