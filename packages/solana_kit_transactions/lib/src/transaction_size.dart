import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

import 'package:solana_kit_transactions/src/codecs/transaction_codec.dart';
import 'package:solana_kit_transactions/src/compile_transaction.dart';
import 'package:solana_kit_transactions/src/transaction.dart';

/// The maximum size of a legacy or version 0 transaction in bytes.
///
/// This is the legacy IPv6 packet payload limit of 1232 bytes. Upstream's
/// fixed-size constants (`TRANSACTION_PACKET_SIZE`, `TRANSACTION_PACKET_HEADER`,
/// and `TRANSACTION_SIZE_LIMIT`) were removed in @solana/kit v8.0.0 (#1948)
/// because version 1 transactions have a larger size limit; use
/// [getTransactionSizeLimit] to derive the limit for a specific transaction, or
/// the per-version constants [legacyTransactionSizeLimit] and
/// [v1TransactionSizeLimit].
const int legacyTransactionSizeLimit = 1232;

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
      TransactionVersion.v0 => legacyTransactionSizeLimit,
      TransactionVersion.v1 => transactionV1SizeLimit,
    };
  }

  if (versionOrTransaction is Transaction) {
    if (versionOrTransaction.messageBytes.isEmpty) {
      return legacyTransactionSizeLimit;
    }

    const versionPrefixMask = 0x80;
    const versionFlagMask = 0x7f;
    final firstMessageByte = versionOrTransaction.messageBytes.first;
    if (firstMessageByte & versionPrefixMask == 0) {
      return legacyTransactionSizeLimit;
    }

    final version = firstMessageByte & versionFlagMask;
    return version == 1 ? transactionV1SizeLimit : legacyTransactionSizeLimit;
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
