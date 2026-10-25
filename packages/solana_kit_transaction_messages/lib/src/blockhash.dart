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

/// The blockhash is stored on the wire as a fixed 32-byte token, so the value
/// must be a base58 string that decodes to exactly 32 bytes.
///
/// Without this check, a blockhash that decodes to more than 32 bytes is
/// silently truncated and one that decodes to fewer is silently zero-extended
/// by the fixed-size lifetime-token encoder, producing a wire lifetime token
/// that differs from the caller-supplied string — for example after a
/// compromised RPC returns a malformed `getLatestBlockhash` value.
void _assertValidBlockhashFormat(String blockhash) {
  if (blockhash.length < 32 || blockhash.length > 44) {
    throw SolanaError(SolanaErrorCode.transactionInvalidBlockhashFormat, {
      'actualLength': blockhash.length,
    });
  }

  final int actualLength;
  try {
    actualLength = getBase58Encoder().encode(blockhash).length;
  } on Object {
    throw SolanaError(SolanaErrorCode.transactionInvalidBlockhashFormat, {
      'actualLength': blockhash.length,
    });
  }

  if (actualLength != 32) {
    throw SolanaError(SolanaErrorCode.transactionInvalidBlockhashFormat, {
      'actualLength': actualLength,
    });
  }
}

/// Given a blockhash and the last block height at which that blockhash is
/// considered usable, this method will return a new transaction message with
/// the lifetime constraint set to the given blockhash constraint.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionInvalidBlockhashFormat] if the blockhash is
/// not a base58 string that decodes to exactly 32 bytes, so a malformed
/// value — for example one served by a compromised RPC — fails loudly
/// instead of being silently truncated or zero-extended on the wire.
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
  _assertValidBlockhashFormat(blockhashLifetimeConstraint.blockhash);

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
