import 'package:solana_kit_rpc_types/src/commitment.dart';
import 'package:solana_kit_rpc_types/src/transaction_error.dart';

/// The result envelope shared by every mode of `getTransactionsForAddress`.
class GetTransactionsForAddressApiResponse<T> {
  /// Creates a response envelope.
  const GetTransactionsForAddressApiResponse({
    required this.data,
    required this.paginationToken,
  });

  /// The matching transactions, ordered according to the requested
  /// `sortOrder`.
  final List<T> data;

  /// A cursor to continue scanning from where this response left off, or
  /// `null` when there are no more results.
  final String? paginationToken;
}

/// A transaction signature entry from `getTransactionsForAddress` in
/// `transactionDetails: 'signatures'` mode.
class GetTransactionsForAddressSignature {
  /// Creates a signature entry.
  const GetTransactionsForAddressSignature({
    required this.blockTime,
    required this.confirmationStatus,
    required this.err,
    required this.memo,
    required this.signature,
    required this.slot,
    required this.transactionIndex,
  });

  /// The estimated production time of when the transaction was processed.
  /// `null` if not available.
  final int? blockTime;

  /// The transaction's cluster confirmation status.
  final Commitment? confirmationStatus;

  /// Error if the transaction failed, `null` if the transaction succeeded.
  final TransactionError? err;

  /// Memo associated with the transaction, `null` if no memo is present.
  final String? memo;

  /// The transaction signature as a base-58 encoded string.
  final String signature;

  /// The slot that contains the block with the transaction.
  final BigInt slot;

  /// The 0-based index of the transaction within its block.
  final int transactionIndex;
}

/// The base fields shared by every `transactionDetails: 'full'` entry from
/// `getTransactionsForAddress`.
class GetTransactionsForAddressFullBase {
  /// Creates a full entry base.
  const GetTransactionsForAddressFullBase({
    required this.blockTime,
    required this.slot,
    required this.transactionIndex,
  });

  /// The estimated production time of when the transaction was processed.
  /// `null` if not available.
  final int? blockTime;

  /// The slot that contains the block with the transaction.
  final BigInt slot;

  /// The 0-based index of the transaction within its block.
  final int transactionIndex;
}
