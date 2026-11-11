import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_privacy_rings/src/codec/transact.dart';
import 'package:solana_kit_privacy_rings/src/constants.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/pdas.dart';

/// Where a withdrawal pays a public balance.
sealed class WithdrawalTarget {
  const WithdrawalTarget();
}

/// Withdraw native SOL to [recipient].
class SolWithdrawalTarget extends WithdrawalTarget {
  /// Creates a SOL withdrawal target.
  const SolWithdrawalTarget(this.recipient);

  /// Public SOL recipient.
  final Address recipient;
}

/// Withdraw an SPL or Token-2022 token to [recipientTokenAccount].
class SplWithdrawalTarget extends WithdrawalTarget {
  /// Creates an SPL withdrawal target.
  const SplWithdrawalTarget({
    required this.mint,
    required this.recipientTokenAccount,
    required this.tokenProgram,
    required this.splInterface,
  });

  /// Mint being withdrawn.
  final Address mint;

  /// Recipient token account.
  final Address recipientTokenAccount;

  /// Token program that owns [mint].
  final Address tokenProgram;

  /// The mint's SPL interface PDA.
  final Address splInterface;
}

/// Builds a single-tree `transact` instruction.
///
/// Account order matches `transactInstruction` in
/// `sdk-libs/ts/src/interface/instructions/index.ts`. [data] is the
/// instruction body. For a transfer or withdrawal, that body includes the
/// Groth16 proof returned by [the remote prover](https://www.helius.dev/docs/privacy/endpoints).
/// This function does not invent a proof.
///
/// [withdrawal] is set for an unshield and omitted for a confidential
/// transfer. It must agree with the single withdrawal leg inside [data].
Future<Instruction> transactInstruction({
  required Address payer,
  required Address inputTree,
  required Address outputTree,
  required List<Address> ownerSigners,
  required TransactInstructionData data,
  WithdrawalTarget? withdrawal,
}) async {
  _checkWithdrawal(data, withdrawal);
  if (data.treeContexts.length != 1 ||
      data.inputs.any((input) => input.treeIndex != 0)) {
    throw PrivacyRingsException(
      'this builder requires one input tree and tree index 0 on every input',
      code: 'invalid_shape',
    );
  }
  final accounts = <AccountMeta>[
    AccountMeta(address: payer, role: AccountRole.writableSigner),
    AccountMeta(address: outputTree, role: AccountRole.writable),
    const AccountMeta(
      address: shieldedPoolProgramId,
      role: AccountRole.readonly,
    ),
    const AccountMeta(
      address: systemProgramAddress,
      role: AccountRole.readonly,
    ),
    AccountMeta(address: inputTree, role: AccountRole.writable),
  ];
  for (final input in data.inputs) {
    accounts.add(
      AccountMeta(
        address: await nullifierPda(inputTree, input.nullifierHash),
        role: AccountRole.writable,
      ),
    );
  }
  for (final signer in ownerSigners) {
    accounts.add(
      AccountMeta(address: signer, role: AccountRole.readonlySigner),
    );
  }
  accounts.addAll(_settlement(withdrawal));
  return Instruction(
    programAddress: shieldedPoolProgramId,
    accounts: accounts,
    data: Uint8List.fromList([
      transactInstructionTag,
      ...encodeTransactInstructionData(data),
    ]),
  );
}

/// Confidential transfer: a `transact` with no public withdrawal.
Future<Instruction> confidentialTransferInstruction({
  required Address payer,
  required Address inputTree,
  required Address outputTree,
  required List<Address> ownerSigners,
  required TransactInstructionData data,
}) {
  return transactInstruction(
    payer: payer,
    inputTree: inputTree,
    outputTree: outputTree,
    ownerSigners: ownerSigners,
    data: data,
  );
}

/// Withdrawal (unshield): a `transact` that pays [withdrawal].
Future<Instruction> withdrawInstruction({
  required Address payer,
  required Address inputTree,
  required Address outputTree,
  required List<Address> ownerSigners,
  required WithdrawalTarget withdrawal,
  required TransactInstructionData data,
}) {
  return transactInstruction(
    payer: payer,
    inputTree: inputTree,
    outputTree: outputTree,
    ownerSigners: ownerSigners,
    data: data,
    withdrawal: withdrawal,
  );
}

void _checkWithdrawal(
  TransactInstructionData data,
  WithdrawalTarget? withdrawal,
) {
  final withdrawals = data.interfaceTransfers.where(
    (transfer) =>
        transfer is SolWithdrawalTransfer || transfer is SplWithdrawalTransfer,
  );
  if (withdrawal == null) {
    if (withdrawals.isNotEmpty) {
      throw PrivacyRingsException(
        'instruction data withdraws, but no withdrawal target was given',
        code: 'withdrawal_mismatch',
      );
    }
    return;
  }
  if (withdrawals.length != 1 || data.interfaceTransfers.length != 1) {
    throw PrivacyRingsException(
      'this builder supports one withdrawal leg and no other interface transfer',
      code: 'withdrawal_mismatch',
    );
  }
  final leg = data.interfaceTransfers.single;
  switch (withdrawal) {
    case SolWithdrawalTarget() when leg is! SolWithdrawalTransfer:
      throw PrivacyRingsException(
        'withdrawal target is SOL but the instruction data is not',
        code: 'withdrawal_mismatch',
      );
    case SplWithdrawalTarget() when leg is! SplWithdrawalTransfer:
      throw PrivacyRingsException(
        'withdrawal target is SPL but the instruction data is not',
        code: 'withdrawal_mismatch',
      );
    case SolWithdrawalTarget():
    case SplWithdrawalTarget():
      return;
  }
}

List<AccountMeta> _settlement(WithdrawalTarget? withdrawal) {
  if (withdrawal == null) return const [];
  return switch (withdrawal) {
    SolWithdrawalTarget(:final recipient) => [
      const AccountMeta(
        address: solInterfaceAddress,
        role: AccountRole.writable,
      ),
      AccountMeta(address: recipient, role: AccountRole.writable),
    ],
    SplWithdrawalTarget(
      :final mint,
      :final recipientTokenAccount,
      :final tokenProgram,
      :final splInterface,
    ) =>
      [
        const AccountMeta(
          address: shieldedPoolCpiAuthority,
          role: AccountRole.readonly,
        ),
        AccountMeta(address: mint, role: AccountRole.readonly),
        AccountMeta(address: splInterface, role: AccountRole.writable),
        AccountMeta(address: recipientTokenAccount, role: AccountRole.writable),
        AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      ],
  };
}
