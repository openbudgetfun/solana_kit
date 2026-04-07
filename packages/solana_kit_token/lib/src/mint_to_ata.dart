import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_associated_token_account/solana_kit_associated_token_account.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:solana_kit_token/src/generated/instructions/mint_to_checked.dart';
import 'package:solana_kit_token/src/generated/programs/token.dart';

/// Input for [getMintToAtaInstructionPlan].
class MintToAtaInput {
  /// Creates a [MintToAtaInput].
  const MintToAtaInput({
    required this.payer,
    required this.ata,
    required this.owner,
    required this.mint,
    required this.mintAuthority,
    required this.amount,
    required this.decimals,
  });

  /// Funding account for ATA creation.
  final Address payer;

  /// Associated token account address to mint to.
  ///
  /// Use `findAssociatedTokenPda` to derive this, or use
  /// [getMintToAtaInstructionPlanAsync] to derive it automatically.
  final Address ata;

  /// Wallet address that owns the ATA.
  final Address owner;

  /// The token mint.
  final Address mint;

  /// The mint authority (or its address if using multisig).
  final Address mintAuthority;

  /// The amount of tokens to mint.
  final BigInt amount;

  /// Expected number of decimals for the mint.
  final int decimals;
}

/// Configuration for mint-to-ATA helpers.
class MintToAtaConfig {
  /// Creates a [MintToAtaConfig].
  const MintToAtaConfig({
    this.tokenProgram,
    this.associatedTokenProgram,
    this.systemProgram,
  });

  /// Token program address. Defaults to [tokenProgramAddress].
  final Address? tokenProgram;

  /// Associated Token program address. Defaults to
  /// [associatedTokenProgramAddress].
  final Address? associatedTokenProgram;

  /// System program address. Defaults to [systemProgramAddress].
  final Address? systemProgram;
}

/// Creates an instruction plan that:
/// 1. Creates the ATA idempotently (no-op if it already exists).
/// 2. Mints tokens to that ATA using `MintToChecked`.
InstructionPlan getMintToAtaInstructionPlan(
  MintToAtaInput input, [
  MintToAtaConfig config = const MintToAtaConfig(),
]) {
  final tokenProgram = config.tokenProgram ?? tokenProgramAddress;
  final ataProgram =
      config.associatedTokenProgram ?? associatedTokenProgramAddress;
  final systemProgram = config.systemProgram ?? systemProgramAddress;

  return sequentialInstructionPlan([
    getCreateAssociatedTokenIdempotentInstruction(
      programAddress: ataProgram,
      payer: input.payer,
      ata: input.ata,
      owner: input.owner,
      mint: input.mint,
      systemProgram: systemProgram,
      tokenProgram: tokenProgram,
    ),
    getMintToCheckedInstruction(
      programAddress: tokenProgram,
      mint: input.mint,
      token: input.ata,
      mintAuthority: input.mintAuthority,
      amount: input.amount,
      decimals: input.decimals,
    ),
  ]);
}

/// Like [getMintToAtaInstructionPlan], but derives the ATA address
/// automatically from [owner] and [mint].
Future<InstructionPlan> getMintToAtaInstructionPlanAsync({
  required Address payer,
  required Address owner,
  required Address mint,
  required Address mintAuthority,
  required BigInt amount,
  required int decimals,
  MintToAtaConfig config = const MintToAtaConfig(),
}) async {
  final tokenProgram = config.tokenProgram ?? tokenProgramAddress;
  final ataProgram =
      config.associatedTokenProgram ?? associatedTokenProgramAddress;

  final (ata, _) = await findAssociatedTokenPda(
    seeds: AssociatedTokenSeeds(
      owner: owner,
      tokenProgram: tokenProgram,
      mint: mint,
    ),
    programAddress: ataProgram,
  );

  return getMintToAtaInstructionPlan(
    MintToAtaInput(
      payer: payer,
      ata: ata,
      owner: owner,
      mint: mint,
      mintAuthority: mintAuthority,
      amount: amount,
      decimals: decimals,
    ),
    config,
  );
}
