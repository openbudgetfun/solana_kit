import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/durable_nonce_instruction.dart';
import 'package:solana_kit_transaction_messages/src/lifetime.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

/// Configuration for setting a durable nonce lifetime on a transaction message.
class DurableNonceConfig {
  /// Creates a [DurableNonceConfig].
  const DurableNonceConfig({
    required this.nonce,
    required this.nonceAccountAddress,
    required this.nonceAuthorityAddress,
  });

  /// The nonce value.
  final String nonce;

  /// The address of the nonce account.
  final Address nonceAccountAddress;

  /// The address of the nonce authority.
  final Address nonceAuthorityAddress;
}

/// Returns `true` if the transaction message has a durable nonce lifetime
/// constraint with a valid advance nonce instruction as the first instruction.
bool isTransactionMessageWithDurableNonceLifetime(
  TransactionMessage transactionMessage,
) {
  final constraint = transactionMessage.lifetimeConstraint;
  if (constraint is! DurableNonceLifetimeConstraint) return false;
  if (transactionMessage.instructions.isEmpty) return false;
  return isAdvanceNonceAccountInstruction(transactionMessage.instructions[0]);
}

/// Asserts that the transaction message has a durable nonce lifetime
/// constraint.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionExpectedNonceLifetime] if the assertion fails.
void assertIsTransactionMessageWithDurableNonceLifetime(
  TransactionMessage transactionMessage,
) {
  if (!isTransactionMessageWithDurableNonceLifetime(transactionMessage)) {
    throw SolanaError(SolanaErrorCode.transactionExpectedNonceLifetime);
  }
}

bool _isAdvanceNonceAccountInstructionForNonce(
  Instruction instruction,
  Address nonceAccountAddress,
  Address nonceAuthorityAddress,
) {
  return instruction.accounts![0].address == nonceAccountAddress &&
      instruction.accounts![2].address == nonceAuthorityAddress;
}

/// Given a nonce, the account where the value of the nonce is stored, and the
/// address of the account authorized to consume that nonce, this method will
/// return a new transaction message with a durable nonce lifetime.
///
/// In particular, this method prepends an instruction to the transaction
/// message designed to consume (or 'advance') the nonce in the same
/// transaction whose lifetime is defined by it.
TransactionMessage setTransactionMessageLifetimeUsingDurableNonce(
  DurableNonceConfig config,
  TransactionMessage transactionMessage,
) {
  List<Instruction> newInstructions;

  final firstInstruction = transactionMessage.instructions.isNotEmpty
      ? transactionMessage.instructions[0]
      : null;

  if (firstInstruction != null &&
      isAdvanceNonceAccountInstruction(firstInstruction)) {
    if (_isAdvanceNonceAccountInstructionForNonce(
      firstInstruction,
      config.nonceAccountAddress,
      config.nonceAuthorityAddress,
    )) {
      final existingConstraint = transactionMessage.lifetimeConstraint;
      if (isTransactionMessageWithDurableNonceLifetime(transactionMessage) &&
          existingConstraint is DurableNonceLifetimeConstraint &&
          existingConstraint.nonce == config.nonce) {
        return transactionMessage;
      } else {
        // We already have the right first instruction, leave it as-is.
        newInstructions = [
          firstInstruction,
          ...transactionMessage.instructions.skip(1),
        ];
      }
    } else {
      // We have a different advance nonce instruction; replace it.
      newInstructions = [
        createAdvanceNonceAccountInstruction(
          config.nonceAccountAddress,
          config.nonceAuthorityAddress,
        ),
        ...transactionMessage.instructions.skip(1),
      ];
    }
  } else {
    // No existing advance nonce instruction; prepend one.
    newInstructions = [
      createAdvanceNonceAccountInstruction(
        config.nonceAccountAddress,
        config.nonceAuthorityAddress,
      ),
      ...transactionMessage.instructions,
    ];
  }

  return transactionMessage.copyWith(
    instructions: List<Instruction>.unmodifiable(newInstructions),
    lifetimeConstraint: DurableNonceLifetimeConstraint(nonce: config.nonce),
  );
}
