import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_transaction_messages/src/lifetime.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

/// Returns `true` if a given string is a valid blockhash (base58 string that
/// decodes to exactly 32 bytes).
bool _isBlockhash(String value) {
  if (value.length < 32 || value.length > 44) return false;
  try {
    final bytes = getBase58Encoder().encode(value);
    return bytes.length == 32;
  } on Object {
    return false;
  }
}

/// Returns `true` if the transaction message has a blockhash-based lifetime
/// constraint.
bool isTransactionMessageWithBlockhashLifetime(
  TransactionMessage transactionMessage,
) {
  final constraint = transactionMessage.lifetimeConstraint;
  return constraint is BlockhashLifetimeConstraint &&
      _isBlockhash(constraint.blockhash);
}

/// Asserts that the transaction message has a blockhash-based lifetime
/// constraint.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionExpectedBlockhashLifetime] if the assertion
/// fails.
void assertIsTransactionMessageWithBlockhashLifetime(
  TransactionMessage transactionMessage,
) {
  if (!isTransactionMessageWithBlockhashLifetime(transactionMessage)) {
    throw SolanaError(SolanaErrorCode.transactionExpectedBlockhashLifetime);
  }
}

/// Given a blockhash and the last block height at which that blockhash is
/// considered usable, this method will return a new transaction message with
/// the lifetime constraint set to the given blockhash constraint.
///
/// Returns the same instance if the lifetime constraint is already set to
/// the same blockhash constraint.
///
/// ```dart
/// final latestBlockhash = await rpc.getLatestBlockhash().send();
/// final txWithBlockhash = setTransactionMessageLifetimeUsingBlockhash(
///   BlockhashLifetimeConstraint(
///     blockhash: latestBlockhash.blockhash,
///     lastValidBlockHeight: latestBlockhash.lastValidBlockHeight,
///   ),
///   txMessage,
/// );
/// ```
TransactionMessage setTransactionMessageLifetimeUsingBlockhash(
  BlockhashLifetimeConstraint blockhashLifetimeConstraint,
  TransactionMessage transactionMessage,
) {
  final existing = transactionMessage.lifetimeConstraint;
  if (existing is BlockhashLifetimeConstraint &&
      existing.blockhash == blockhashLifetimeConstraint.blockhash &&
      existing.lastValidBlockHeight ==
          blockhashLifetimeConstraint.lastValidBlockHeight) {
    return transactionMessage;
  }

  return transactionMessage.copyWith(
    lifetimeConstraint: blockhashLifetimeConstraint,
  );
}
