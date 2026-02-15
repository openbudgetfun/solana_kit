import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

import 'package:solana_kit_transactions/src/codecs/transaction_codec.dart';
import 'package:solana_kit_transactions/src/compile_transaction.dart';
import 'package:solana_kit_transactions/src/transaction.dart';

/// The maximum size of a transaction packet in bytes.
const transactionPacketSize = 1280;

/// The size of the transaction packet header in bytes.
/// This includes the IPv6 header (40 bytes) and the fragment header (8 bytes).
const transactionPacketHeader = 40 + 8;

/// The maximum size of a transaction in bytes.
///
/// Note that this excludes the transaction packet header.
/// In other words, this is how much content we can fit in a transaction packet.
const transactionSizeLimit = transactionPacketSize - transactionPacketHeader;

/// Gets the size of a given transaction in bytes.
int getTransactionSize(Transaction transaction) {
  final encoder = getTransactionEncoder();
  return encoder.getSizeFromValue(transaction);
}

/// Returns `true` if the transaction is within the size limit.
bool isTransactionWithinSizeLimit(Transaction transaction) {
  return getTransactionSize(transaction) <= transactionSizeLimit;
}

/// Asserts that a given transaction is within the size limit.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionExceedsSizeLimit] if the transaction exceeds
/// the size limit.
void assertIsTransactionWithinSizeLimit(Transaction transaction) {
  final size = getTransactionSize(transaction);
  if (size > transactionSizeLimit) {
    throw SolanaError(SolanaErrorCode.transactionExceedsSizeLimit, {
      'transactionSize': size,
      'transactionSizeLimit': transactionSizeLimit,
    });
  }
}

/// Gets the compiled transaction size of a given transaction message in bytes.
int getTransactionMessageSize(TransactionMessage transactionMessage) {
  return getTransactionSize(compileTransaction(transactionMessage));
}

/// Checks if a transaction message is within the size limit when compiled
/// into a transaction.
bool isTransactionMessageWithinSizeLimit(
  TransactionMessage transactionMessage,
) {
  return getTransactionMessageSize(transactionMessage) <= transactionSizeLimit;
}

/// Asserts that a given transaction message is within the size limit when
/// compiled into a transaction.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionExceedsSizeLimit] if the transaction message
/// exceeds the size limit.
void assertIsTransactionMessageWithinSizeLimit(
  TransactionMessage transactionMessage,
) {
  final size = getTransactionMessageSize(transactionMessage);
  if (size > transactionSizeLimit) {
    throw SolanaError(SolanaErrorCode.transactionExceedsSizeLimit, {
      'transactionSize': size,
      'transactionSizeLimit': transactionSizeLimit,
    });
  }
}
