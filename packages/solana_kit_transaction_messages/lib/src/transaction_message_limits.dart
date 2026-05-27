import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/compile_accounts.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

/// The maximum number of unique signer addresses in a transaction message.
const maxTransactionSignerAddresses = 12;

/// The maximum number of unique account addresses in a transaction message.
const maxTransactionAccountAddresses = 64;

/// The maximum number of instructions in a transaction message.
const maxTransactionInstructions = 64;

/// The maximum number of account references in a single instruction.
const maxAccountsPerInstruction = 255;

/// Asserts that [transactionMessage] satisfies the transaction message limits
/// enforced by the Agave runtime.
void assertTransactionMessageIsWithinLimits(
  TransactionMessage transactionMessage, {
  List<OrderedAccount>? orderedAccounts,
}) {
  final instructions = transactionMessage.instructions;
  final feePayer = transactionMessage.feePayer;
  final accounts =
      orderedAccounts ??
      (feePayer == null
          ? null
          : getOrderedAccountsFromInstructions(feePayer, instructions));

  if (accounts != null) {
    if (accounts.length > maxTransactionAccountAddresses) {
      throw SolanaError(SolanaErrorCode.transactionTooManyAccountAddresses, {
        'actualCount': accounts.length,
        'maxAllowed': maxTransactionAccountAddresses,
      });
    }

    final signerCount = accounts.where(_isSignerAccount).length;
    if (signerCount > maxTransactionSignerAddresses) {
      throw SolanaError(SolanaErrorCode.transactionTooManySignerAddresses, {
        'actualCount': signerCount,
        'maxAllowed': maxTransactionSignerAddresses,
      });
    }
  }

  if (instructions.length > maxTransactionInstructions) {
    throw SolanaError(SolanaErrorCode.transactionTooManyInstructions, {
      'actualCount': instructions.length,
      'maxAllowed': maxTransactionInstructions,
    });
  }

  for (var index = 0; index < instructions.length; index++) {
    final accountCount = instructions[index].accounts?.length ?? 0;
    if (accountCount > maxAccountsPerInstruction) {
      throw SolanaError(
        SolanaErrorCode.transactionTooManyAccountsInInstruction,
        {
          'instructionIndex': index,
          'actualCount': accountCount,
          'maxAllowed': maxAccountsPerInstruction,
        },
      );
    }
  }
}

bool _isSignerAccount(OrderedAccount account) => isSignerRole(account.role);
