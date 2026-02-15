import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/src/account_signer_meta.dart';
import 'package:solana_kit_signers/src/deduplicate_signers.dart';
import 'package:solana_kit_signers/src/fee_payer_signer.dart';
import 'package:solana_kit_signers/src/transaction_signer.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

/// Attaches the provided transaction signers to the account metas of an
/// instruction when applicable.
///
/// For an account meta to match a provided signer it:
/// - Must have a signer role ([AccountRole.readonlySigner] or
///   [AccountRole.writableSigner]).
/// - Must have the same address as the provided signer.
/// - Must not have an attached signer already.
Instruction addSignersToInstruction(
  List<Object> signers,
  Instruction instruction,
) {
  if (instruction.accounts == null || instruction.accounts!.isEmpty) {
    return instruction;
  }

  final deduplicatedSigners = deduplicateSigners(signers);
  final signerByAddress = {
    for (final signer in deduplicatedSigners)
      getTransactionSignerAddress(signer): signer,
  };

  final updatedAccounts = instruction.accounts!.map((account) {
    final signer = signerByAddress[account.address];
    if (!isSignerRole(account.role) ||
        account is AccountSignerMeta ||
        signer == null) {
      return account;
    }
    return AccountSignerMeta(
      address: account.address,
      role: account.role,
      signer: signer,
    );
  }).toList();

  return Instruction(
    programAddress: instruction.programAddress,
    accounts: updatedAccounts,
    data: instruction.data,
  );
}

/// Attaches the provided transaction signers to the account metas of all
/// instructions inside a transaction message and/or the transaction
/// message fee payer, when applicable.
///
/// For an account meta to match a provided signer it:
/// - Must have a signer role ([AccountRole.readonlySigner] or
///   [AccountRole.writableSigner]).
/// - Must have the same address as the provided signer.
/// - Must not have an attached signer already.
TransactionMessage addSignersToTransactionMessage(
  List<Object> signers,
  TransactionMessage transactionMessage,
) {
  // Check if the fee payer is an address-only fee payer (not a signer).
  Object? feePayerSigner;
  if (transactionMessage is! TransactionMessageWithFeePayerSigner &&
      transactionMessage.feePayer != null) {
    // Find a signer that matches the fee payer address.
    for (final signer in signers) {
      if (getTransactionSignerAddress(signer) == transactionMessage.feePayer) {
        feePayerSigner = signer;
        break;
      }
    }
  }

  if (feePayerSigner == null && transactionMessage.instructions.isEmpty) {
    return transactionMessage;
  }

  final updatedInstructions = transactionMessage.instructions
      .map((instruction) => addSignersToInstruction(signers, instruction))
      .toList();

  if (feePayerSigner != null) {
    return TransactionMessageWithFeePayerSigner(
      feePayerSigner: feePayerSigner,
      version: transactionMessage.version,
      instructions: updatedInstructions,
      lifetimeConstraint: transactionMessage.lifetimeConstraint,
    );
  }

  if (transactionMessage is TransactionMessageWithFeePayerSigner) {
    return TransactionMessageWithFeePayerSigner(
      feePayerSigner: transactionMessage.feePayerSigner,
      version: transactionMessage.version,
      instructions: updatedInstructions,
      lifetimeConstraint: transactionMessage.lifetimeConstraint,
    );
  }

  return transactionMessage.copyWith(instructions: updatedInstructions);
}
