import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:solana_kit_token/src/generated/instructions/create_associated_token_idempotent.dart';
import 'package:solana_kit_token/src/generated/instructions/transfer_checked.dart';
import 'package:solana_kit_token/src/generated/pdas/associated_token.dart';
import 'package:solana_kit_token/src/generated/programs/associated_token.dart';
import 'package:solana_kit_token/src/generated/programs/token.dart';

/// Input for [getTransferToAtaInstructionPlan].
class TransferToAtaInput {
  /// Creates a [TransferToAtaInput].
  const TransferToAtaInput({
    required this.payer,
    required this.mint,
    required this.source,
    required this.authority,
    required this.destination,
    required this.recipient,
    required this.amount,
    required this.decimals,
  });

  /// Funding account for ATA creation.
  final Address payer;

  /// The token mint.
  final Address mint;

  /// The source token account.
  final Address source;

  /// The source account's owner/delegate.
  final Address authority;

  /// The destination ATA address.
  ///
  /// Derive with the generated PDA helper, or use the async variant
  /// to derive it automatically.
  final Address destination;

  /// Wallet address that owns the destination ATA.
  final Address recipient;

  /// The amount of tokens to transfer.
  final BigInt amount;

  /// Expected number of decimals for the mint.
  final int decimals;
}

/// Configuration for transfer-to-ATA helpers.
class TransferToAtaConfig {
  /// Creates a [TransferToAtaConfig].
  const TransferToAtaConfig({
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
/// 1. Creates the destination ATA idempotently (no-op if it already exists).
/// 2. Transfers tokens from source to destination using `TransferChecked`.
InstructionPlan getTransferToAtaInstructionPlan(
  TransferToAtaInput input, [
  TransferToAtaConfig config = const TransferToAtaConfig(),
]) {
  final tokenProgram = config.tokenProgram ?? tokenProgramAddress;
  final ataProgram =
      config.associatedTokenProgram ?? associatedTokenProgramAddress;
  final systemProgram = config.systemProgram ?? systemProgramAddress;

  return sequentialInstructionPlan([
    getCreateAssociatedTokenIdempotentInstruction(
      programAddress: ataProgram,
      payer: input.payer,
      ata: input.destination,
      owner: input.recipient,
      mint: input.mint,
      systemProgram: systemProgram,
      tokenProgram: tokenProgram,
    ),
    getTransferCheckedInstruction(
      programAddress: tokenProgram,
      source: input.source,
      mint: input.mint,
      destination: input.destination,
      authority: input.authority,
      amount: input.amount,
      decimals: input.decimals,
    ),
  ]);
}

/// Like [getTransferToAtaInstructionPlan], but derives source and
/// destination ATA addresses automatically.
Future<InstructionPlan> getTransferToAtaInstructionPlanAsync({
  required Address payer,
  required Address mint,
  required Address authority,
  required Address recipient,
  required BigInt amount,
  required int decimals,
  TransferToAtaConfig config = const TransferToAtaConfig(),
}) async {
  final tokenProgram = config.tokenProgram ?? tokenProgramAddress;
  final ataProgram =
      config.associatedTokenProgram ?? associatedTokenProgramAddress;

  final (destination, _) = await findAssociatedTokenPda(
    seeds: AssociatedTokenSeeds(
      owner: recipient,
      tokenProgram: tokenProgram,
      mint: mint,
    ),
    programAddress: ataProgram,
  );

  final (source, _) = await findAssociatedTokenPda(
    seeds: AssociatedTokenSeeds(
      owner: authority,
      tokenProgram: tokenProgram,
      mint: mint,
    ),
    programAddress: ataProgram,
  );

  return getTransferToAtaInstructionPlan(
    TransferToAtaInput(
      payer: payer,
      mint: mint,
      source: source,
      authority: authority,
      destination: destination,
      recipient: recipient,
      amount: amount,
      decimals: decimals,
    ),
    config,
  );
}
