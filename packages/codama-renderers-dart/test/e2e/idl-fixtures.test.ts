import { existsSync, mkdirSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { visit } from "@codama/visitors-core";
import { rootNodeFromAnchor } from "@codama/nodes-from-anchor";

import { renderVisitor } from "../../src/visitors/renderVisitor.js";
import { getRenderMapVisitor } from "../../src/visitors/getRenderMapVisitor.js";

import tokenVaultIdl from "../fixtures/token_vault.json";
import stakingIdl from "../fixtures/staking.json";

/**
 * Load and convert an Anchor IDL JSON to a Codama root node.
 */
function loadIdl(idl: any) {
  return rootNodeFromAnchor(idl);
}

describe("E2E: Token Vault IDL fixture", () => {
  let outputDir: string;
  let root: ReturnType<typeof loadIdl>;

  beforeEach(() => {
    outputDir = join(tmpdir(), `codama-dart-vault-${Date.now()}-${Math.random().toString(36).slice(2)}`);
    mkdirSync(outputDir, { recursive: true });
    root = loadIdl(tokenVaultIdl);
  });

  afterEach(() => {
    if (existsSync(outputDir)) {
      rmSync(outputDir, { recursive: true, force: true });
    }
  });

  it("should parse the token vault IDL into a valid root node", () => {
    expect(root).toBeDefined();
    expect(root.kind).toBe("rootNode");
    expect(root.program.name).toBe("tokenVault");
  });

  it("should generate expected directory structure", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));

    // Root barrel
    expect(existsSync(join(outputDir, "token_vault.dart"))).toBe(true);

    // Accounts
    expect(existsSync(join(outputDir, "accounts/accounts.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "accounts/vault.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "accounts/deposit_record.dart"))).toBe(true);

    // Instructions
    expect(existsSync(join(outputDir, "instructions/instructions.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "instructions/initialize_vault.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "instructions/deposit.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "instructions/withdraw.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "instructions/update_vault_status.dart"))).toBe(true);

    // Types
    expect(existsSync(join(outputDir, "types/types.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "types/vault_status.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "types/vault_config.dart"))).toBe(true);

    // Errors
    expect(existsSync(join(outputDir, "errors/errors.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "errors/token_vault.dart"))).toBe(true);

    // Programs
    expect(existsSync(join(outputDir, "programs/programs.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "programs/token_vault.dart"))).toBe(true);
  });

  it("should generate correct Vault account code", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "accounts/vault.dart"), "utf-8");

    // Class
    expect(content).toContain("@immutable");
    expect(content).toContain("class Vault {");
    expect(content).toContain("const Vault({");

    // Fields
    expect(content).toContain("final Address authority;");
    expect(content).toContain("final Address tokenMint;");
    expect(content).toContain("final BigInt totalDeposited;");
    expect(content).toContain("final BigInt maxCapacity;");
    expect(content).toContain("final int bumpSeed;");

    // Codec functions
    expect(content).toContain("Encoder<Vault> getVaultEncoder()");
    expect(content).toContain("Decoder<Vault> getVaultDecoder()");
    expect(content).toContain("Codec<Vault, Vault> getVaultCodec()");

    // Account decode helper
    expect(content).toContain("Account<Vault> decodeVault(EncodedAccount encodedAccount)");

    // No interpolation bugs
    expect(content).not.toContain("[object Object]");
  });

  it("should generate correct DepositRecord account code", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "accounts/deposit_record.dart"), "utf-8");

    expect(content).toContain("class DepositRecord {");
    expect(content).toContain("final Address depositor;");
    expect(content).toContain("final Address vault;");
    expect(content).toContain("final BigInt amount;");
    expect(content).toContain("final BigInt timestamp;");

    expect(content).toContain("getDepositRecordEncoder()");
    expect(content).toContain("getDepositRecordDecoder()");
    expect(content).toContain("getDepositRecordCodec()");
  });

  it("should generate correct VaultStatus scalar enum", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "types/vault_status.dart"), "utf-8");

    expect(content).toContain("enum VaultStatus {");
    expect(content).toContain("active,");
    expect(content).toContain("paused,");
    expect(content).toContain("closed,");
    expect(content).toContain("frozen,");

    expect(content).toContain("getVaultStatusEncoder()");
    expect(content).toContain("getVaultStatusDecoder()");
    expect(content).toContain("getVaultStatusCodec()");
    expect(content).toContain("transformEncoder");
    expect(content).toContain("value.index");
  });

  it("should generate correct VaultConfig struct type", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "types/vault_config.dart"), "utf-8");

    expect(content).toContain("class VaultConfig {");
    expect(content).toContain("final BigInt maxCapacity;");
    expect(content).toContain("final BigInt minDeposit;");
    expect(content).toContain("final int feeRate;");
    expect(content).toContain("final bool isActive;");

    expect(content).toContain("getVaultConfigEncoder()");
    expect(content).toContain("getVaultConfigDecoder()");
  });

  it("should generate all 5 error codes", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "errors/token_vault.dart"), "utf-8");

    // Error constants
    expect(content).toContain("tokenVaultErrorInvalidAuthority");
    expect(content).toContain("tokenVaultErrorVaultFull");
    expect(content).toContain("tokenVaultErrorInsufficientFunds");
    expect(content).toContain("tokenVaultErrorVaultNotActive");
    expect(content).toContain("tokenVaultErrorInvalidAmount");

    // Hex codes
    expect(content).toContain("0x1770"); // 6000
    expect(content).toContain("0x1771"); // 6001
    expect(content).toContain("0x1772"); // 6002
    expect(content).toContain("0x1773"); // 6003
    expect(content).toContain("0x1774"); // 6004

    // Error messages
    expect(content).toContain("The provided authority does not match the vault authority.");
    expect(content).toContain("The vault has reached its maximum capacity.");
    expect(content).toContain("Insufficient funds for this withdrawal.");

    // Helper functions
    expect(content).toContain("getTokenVaultErrorMessage");
    expect(content).toContain("isTokenVaultError");
  });

  it("should generate 4 instruction builders", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));

    // InitializeVault
    const initContent = readFileSync(join(outputDir, "instructions/initialize_vault.dart"), "utf-8");
    expect(initContent).toContain("class InitializeVaultInstructionData {");
    expect(initContent).toContain("Instruction getInitializeVaultInstruction({");
    expect(initContent).toContain("required Address programAddress,");
    expect(initContent).toContain("required Address vault,");
    expect(initContent).toContain("required Address authority,");
    expect(initContent).toContain("required Address tokenMint,");
    expect(initContent).toContain("required Address systemProgram,");
    expect(initContent).not.toContain("[object Object]");

    // Deposit
    const depositContent = readFileSync(join(outputDir, "instructions/deposit.dart"), "utf-8");
    expect(depositContent).toContain("class DepositInstructionData {");
    expect(depositContent).toContain("Instruction getDepositInstruction({");
    expect(depositContent).toContain("required Address depositor,");
    expect(depositContent).toContain("required Address depositorTokenAccount,");

    // Withdraw
    const withdrawContent = readFileSync(join(outputDir, "instructions/withdraw.dart"), "utf-8");
    expect(withdrawContent).toContain("class WithdrawInstructionData {");
    expect(withdrawContent).toContain("Instruction getWithdrawInstruction({");

    // UpdateVaultStatus
    const updateContent = readFileSync(join(outputDir, "instructions/update_vault_status.dart"), "utf-8");
    expect(updateContent).toContain("class UpdateVaultStatusInstructionData {");
    expect(updateContent).toContain("Instruction getUpdateVaultStatusInstruction({");
  });

  it("should generate correct program page with address and enums", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "programs/token_vault.dart"), "utf-8");

    // Program address
    expect(content).toContain("tokenVaultProgramAddress");

    // Account enum
    expect(content).toContain("enum TokenVaultAccount {");
    expect(content).toContain("vault,");
    expect(content).toContain("depositRecord,");

    // Instruction enum
    expect(content).toContain("enum TokenVaultInstruction {");
    expect(content).toContain("initializeVault,");
    expect(content).toContain("deposit,");
    expect(content).toContain("withdraw,");
    expect(content).toContain("updateVaultStatus,");
  });

  it("should produce a render map with all expected keys", () => {
    const renderMap = visit(root, getRenderMapVisitor());
    const keys = [...renderMap.keys()].sort();

    expect(keys).toContain("token_vault.dart");
    expect(keys).toContain("accounts/accounts.dart");
    expect(keys).toContain("accounts/vault.dart");
    expect(keys).toContain("accounts/deposit_record.dart");
    expect(keys).toContain("instructions/instructions.dart");
    expect(keys).toContain("instructions/initialize_vault.dart");
    expect(keys).toContain("instructions/deposit.dart");
    expect(keys).toContain("instructions/withdraw.dart");
    expect(keys).toContain("instructions/update_vault_status.dart");
    expect(keys).toContain("types/types.dart");
    expect(keys).toContain("types/vault_status.dart");
    expect(keys).toContain("types/vault_config.dart");
    expect(keys).toContain("errors/errors.dart");
    expect(keys).toContain("errors/token_vault.dart");
    expect(keys).toContain("programs/programs.dart");
    expect(keys).toContain("programs/token_vault.dart");
  });

  it("should generate proper imports in account files", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "accounts/vault.dart"), "utf-8");

    // Standard header
    expect(content).toContain("// Auto-generated. Do not edit.");
    expect(content).toContain("// ignore_for_file: type=lint");

    // Required imports
    expect(content).toContain("import 'dart:typed_data';");
    expect(content).toContain("import 'package:meta/meta.dart';");
    expect(content).toContain("import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';");
    expect(content).toContain("import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';");
  });

  it("should generate correct barrel exports", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));

    // Root barrel
    const rootBarrel = readFileSync(join(outputDir, "token_vault.dart"), "utf-8");
    expect(rootBarrel).toContain("export 'accounts/accounts.dart';");
    expect(rootBarrel).toContain("export 'instructions/instructions.dart';");
    expect(rootBarrel).toContain("export 'types/types.dart';");
    expect(rootBarrel).toContain("export 'errors/errors.dart';");
    expect(rootBarrel).toContain("export 'programs/programs.dart';");

    // Accounts barrel
    const accountsBarrel = readFileSync(join(outputDir, "accounts/accounts.dart"), "utf-8");
    expect(accountsBarrel).toContain("export 'vault.dart';");
    expect(accountsBarrel).toContain("export 'deposit_record.dart';");

    // Instructions barrel
    const instBarrel = readFileSync(join(outputDir, "instructions/instructions.dart"), "utf-8");
    expect(instBarrel).toContain("export 'initialize_vault.dart';");
    expect(instBarrel).toContain("export 'deposit.dart';");
    expect(instBarrel).toContain("export 'withdraw.dart';");
    expect(instBarrel).toContain("export 'update_vault_status.dart';");
  });

  it("should not contain any Fragment interpolation artifacts", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const renderMap = visit(root, getRenderMapVisitor());

    for (const [key, fragment] of renderMap.entries()) {
      expect(fragment.content, `${key} should not contain [object Object]`).not.toContain("[object Object]");
    }
  });
});

describe("E2E: Staking IDL fixture", () => {
  let outputDir: string;
  let root: ReturnType<typeof loadIdl>;

  beforeEach(() => {
    outputDir = join(tmpdir(), `codama-dart-staking-${Date.now()}-${Math.random().toString(36).slice(2)}`);
    mkdirSync(outputDir, { recursive: true });
    root = loadIdl(stakingIdl);
  });

  afterEach(() => {
    if (existsSync(outputDir)) {
      rmSync(outputDir, { recursive: true, force: true });
    }
  });

  it("should parse the staking IDL into a valid root node", () => {
    expect(root).toBeDefined();
    expect(root.kind).toBe("rootNode");
    expect(root.program.name).toBe("staking");
  });

  it("should generate expected directory structure", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));

    // Root barrel
    expect(existsSync(join(outputDir, "staking.dart"))).toBe(true);

    // Accounts
    expect(existsSync(join(outputDir, "accounts/stake_pool.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "accounts/stake_account.dart"))).toBe(true);

    // Instructions
    expect(existsSync(join(outputDir, "instructions/initialize_pool.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "instructions/stake.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "instructions/unstake.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "instructions/claim_rewards.dart"))).toBe(true);

    // Types
    expect(existsSync(join(outputDir, "types/pool_status.dart"))).toBe(true);
    expect(existsSync(join(outputDir, "types/stake_info.dart"))).toBe(true);

    // Errors
    expect(existsSync(join(outputDir, "errors/staking.dart"))).toBe(true);

    // Programs
    expect(existsSync(join(outputDir, "programs/staking.dart"))).toBe(true);
  });

  it("should generate correct StakePool account with many fields", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "accounts/stake_pool.dart"), "utf-8");

    expect(content).toContain("class StakePool {");
    expect(content).toContain("final Address admin;");
    expect(content).toContain("final Address rewardMint;");
    expect(content).toContain("final Address stakeMint;");
    expect(content).toContain("final BigInt totalStaked;");
    expect(content).toContain("final BigInt rewardRate;");
    expect(content).toContain("final BigInt minStakeDuration;");
    expect(content).toContain("final int maxStakers;");
    expect(content).toContain("final int currentStakers;");
    expect(content).toContain("final bool isActive;");
    expect(content).toContain("final int bump;");

    expect(content).toContain("getStakePoolEncoder()");
    expect(content).toContain("getStakePoolDecoder()");
    expect(content).toContain("decodeStakePool(EncodedAccount encodedAccount)");
  });

  it("should generate StakeInfo struct type with optional field", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "types/stake_info.dart"), "utf-8");

    expect(content).toContain("class StakeInfo {");
    expect(content).toContain("final BigInt amount;");
    expect(content).toContain("final BigInt startTime;");
    expect(content).toContain("final bool isLocked;");

    // Optional field (i64? or BigInt?)
    expect(content).toContain("endTime");

    expect(content).toContain("getStakeInfoEncoder()");
    expect(content).toContain("getStakeInfoDecoder()");
  });

  it("should generate PoolStatus scalar enum", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "types/pool_status.dart"), "utf-8");

    expect(content).toContain("enum PoolStatus {");
    expect(content).toContain("uninitialized,");
    expect(content).toContain("active,");
    expect(content).toContain("paused,");
    expect(content).toContain("deprecated,");
  });

  it("should generate 6 error codes for staking program", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "errors/staking.dart"), "utf-8");

    expect(content).toContain("stakingErrorPoolNotActive");
    expect(content).toContain("stakingErrorMaxStakersReached");
    expect(content).toContain("stakingErrorStakeDurationNotMet");
    expect(content).toContain("stakingErrorNoRewardsAvailable");
    expect(content).toContain("stakingErrorInvalidStakeAmount");
    expect(content).toContain("stakingErrorUnauthorized");

    expect(content).toContain("0x1770"); // 6000
    expect(content).toContain("0x1775"); // 6005

    expect(content).toContain("getStakingErrorMessage");
    expect(content).toContain("isStakingError");
  });

  it("should generate instructions with correct account roles", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));

    // Stake instruction: staker is signer+writable
    const stakeContent = readFileSync(join(outputDir, "instructions/stake.dart"), "utf-8");
    expect(stakeContent).toContain("class StakeInstructionData {");
    expect(stakeContent).toContain("Instruction getStakeInstruction({");
    expect(stakeContent).toContain("required Address pool,");
    expect(stakeContent).toContain("required Address staker,");
    expect(stakeContent).toContain("AccountMeta(address: staker, role: AccountRole.writableSigner)");
    expect(stakeContent).toContain("AccountMeta(address: pool, role: AccountRole.writable)");

    // ClaimRewards: staker is signer but not writable
    const claimContent = readFileSync(join(outputDir, "instructions/claim_rewards.dart"), "utf-8");
    expect(claimContent).toContain("Instruction getClaimRewardsInstruction({");
    expect(claimContent).toContain("AccountMeta(address: staker, role: AccountRole.readonlySigner)");
  });

  it("should generate unstake instruction with no args (empty data)", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "instructions/unstake.dart"), "utf-8");

    expect(content).toContain("class UnstakeInstructionData {");
    expect(content).toContain("Instruction getUnstakeInstruction({");
    expect(content).toContain("required Address programAddress,");
  });

  it("should generate program page with accounts and instructions", () => {
    visit(root, renderVisitor(outputDir, { formatCode: false }));
    const content = readFileSync(join(outputDir, "programs/staking.dart"), "utf-8");

    expect(content).toContain("stakingProgramAddress");

    expect(content).toContain("enum StakingAccount {");
    expect(content).toContain("stakePool,");
    expect(content).toContain("stakeAccount,");

    expect(content).toContain("enum StakingInstruction {");
    expect(content).toContain("initializePool,");
    expect(content).toContain("stake,");
    expect(content).toContain("unstake,");
    expect(content).toContain("claimRewards,");
  });

  it("should produce non-empty fragments for all render map entries", () => {
    const renderMap = visit(root, getRenderMapVisitor());

    for (const [key, fragment] of renderMap.entries()) {
      expect(fragment.content, `Fragment for ${key} should have content`).toBeTruthy();
      expect(fragment.content, `${key} should not contain [object Object]`).not.toContain("[object Object]");
    }
  });

  it("should produce a render map with all expected keys for staking program", () => {
    const renderMap = visit(root, getRenderMapVisitor());
    const keys = [...renderMap.keys()].sort();

    expect(keys).toContain("staking.dart");
    expect(keys).toContain("accounts/accounts.dart");
    expect(keys).toContain("accounts/stake_pool.dart");
    expect(keys).toContain("accounts/stake_account.dart");
    expect(keys).toContain("instructions/instructions.dart");
    expect(keys).toContain("instructions/initialize_pool.dart");
    expect(keys).toContain("instructions/stake.dart");
    expect(keys).toContain("instructions/unstake.dart");
    expect(keys).toContain("instructions/claim_rewards.dart");
    expect(keys).toContain("types/types.dart");
    expect(keys).toContain("types/pool_status.dart");
    expect(keys).toContain("types/stake_info.dart");
    expect(keys).toContain("errors/errors.dart");
    expect(keys).toContain("errors/staking.dart");
    expect(keys).toContain("programs/programs.dart");
    expect(keys).toContain("programs/staking.dart");
  });
});
