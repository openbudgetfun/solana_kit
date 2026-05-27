import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

import 'package:solana_kit_transactions/src/codecs/transaction_codec.dart';
import 'package:solana_kit_transactions/src/compile_transaction.dart';
import 'package:solana_kit_transactions/src/transaction.dart';

/// The maximum size of a transaction packet in bytes.
const transactionPacketSize = 1280;

/// The size of the transaction packet header in bytes.
/// This includes the IPv6 header (40 bytes) and the fragment header (8 bytes).
const int transactionPacketHeader = 40 + 8;

/// The maximum size of a legacy or version 0 transaction in bytes.
///
/// Note that this excludes the transaction packet header.
/// In other words, this is how much content we can fit in a transaction packet.
const int transactionSizeLimit =
    transactionPacketSize - transactionPacketHeader;

/// Alias for the legacy and version 0 transaction size limit.
const int legacyTransactionSizeLimit = transactionSizeLimit;

/// The maximum size of a version 1 transaction in bytes.
const int transactionV1SizeLimit = 4096;

/// Alias for the version 1 transaction size limit.
const int v1TransactionSizeLimit = transactionV1SizeLimit;

/// Gets the maximum transaction size for [versionOrTransaction].
///
/// Pass a [TransactionVersion] to query the limit for a message version, or pass
/// a compiled [Transaction] to derive the limit from the wire-format message
/// version byte. Version 1 transactions use Agave's larger 4096-byte limit;
/// legacy and version 0 transactions use the packet payload limit.
int getTransactionSizeLimit(Object versionOrTransaction) {
  if (versionOrTransaction is TransactionVersion) {
    return switch (versionOrTransaction) {
      TransactionVersion.legacy ||
      TransactionVersion.v0 => transactionSizeLimit,
    };
  }

  if (versionOrTransaction is Transaction) {
    if (versionOrTransaction.messageBytes.isEmpty) return transactionSizeLimit;

    const versionFlagMask = 0x7f;
    final version = versionOrTransaction.messageBytes.first & versionFlagMask;
    return version == 1 ? transactionV1SizeLimit : transactionSizeLimit;
  }

  throw ArgumentError.value(
    versionOrTransaction,
    'versionOrTransaction',
    'Expected a TransactionVersion or Transaction.',
  );
}

/// Gets the size of a given transaction in bytes.
int getTransactionSize(Transaction transaction) {
  final encoder = getTransactionEncoder();
  return encoder.getSizeFromValue(transaction);
}

/// Returns `true` if the transaction is within the size limit.
bool isTransactionWithinSizeLimit(Transaction transaction) {
  if (transaction.messageBytes.isEmpty) return true;

  return getTransactionSize(transaction) <=
      getTransactionSizeLimit(transaction);
}

/// Asserts that a given transaction is within the size limit.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionExceedsSizeLimit] if the transaction exceeds
/// the size limit.
void assertIsTransactionWithinSizeLimit(Transaction transaction) {
  if (transaction.messageBytes.isEmpty) return;

  final size = getTransactionSize(transaction);
  final sizeLimit = getTransactionSizeLimit(transaction);
  if (size > sizeLimit) {
    throw SolanaError(SolanaErrorCode.transactionExceedsSizeLimit, {
      'transactionSize': size,
      'transactionSizeLimit': sizeLimit,
    });
  }
}

/// Gets the compiled transaction size of a given transaction message in bytes.
int getTransactionMessageSize(TransactionMessage transactionMessage) {
  return getTransactionSize(compileTransaction(transactionMessage));
}

/// Gets the maximum transaction size for [transactionMessage].
int getTransactionMessageSizeLimit(TransactionMessage transactionMessage) {
  return getTransactionSizeLimit(transactionMessage.version);
}

/// Checks if a transaction message is within the size limit when compiled
/// into a transaction.
bool isTransactionMessageWithinSizeLimit(
  TransactionMessage transactionMessage,
) {
  return getTransactionMessageSize(transactionMessage) <=
      getTransactionMessageSizeLimit(transactionMessage);
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
  final sizeLimit = getTransactionMessageSizeLimit(transactionMessage);
  if (size > sizeLimit) {
    throw SolanaError(SolanaErrorCode.transactionExceedsSizeLimit, {
      'transactionSize': size,
      'transactionSizeLimit': sizeLimit,
    });
  }
}
