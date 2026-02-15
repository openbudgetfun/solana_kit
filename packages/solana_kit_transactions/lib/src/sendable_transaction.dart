import 'package:solana_kit_transactions/src/signatures.dart';
import 'package:solana_kit_transactions/src/transaction.dart';
import 'package:solana_kit_transactions/src/transaction_size.dart';

/// Returns `true` if the transaction has all the required conditions to be
/// sent to the network: fully signed and within the size limit.
bool isSendableTransaction(Transaction transaction) {
  return isFullySignedTransaction(transaction) &&
      isTransactionWithinSizeLimit(transaction);
}

/// Asserts that a given transaction has all the required conditions to be
/// sent to the network.
///
/// Throws if the transaction is not fully signed or exceeds the size limit.
void assertIsSendableTransaction(Transaction transaction) {
  assertIsFullySignedTransaction(transaction);
  assertIsTransactionWithinSizeLimit(transaction);
}
