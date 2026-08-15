import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// A comparison against a block time, signature ordering, or slot.
class GetTransactionsForAddressComparison {
  /// Creates a comparison.
  const GetTransactionsForAddressComparison({
    this.gt,
    this.gte,
    this.lt,
    this.lte,
  });

  /// Match values strictly greater than this.
  final Object? gt;

  /// Match values at or after this.
  final Object? gte;

  /// Match values strictly less than this.
  final Object? lt;

  /// Match values at or before this.
  final Object? lte;

  /// Converts this comparison to a JSON-RPC map.
  Map<String, Object?> toJson() => {
    if (gt != null) 'gt': gt,
    if (gte != null) 'gte': gte,
    if (lt != null) 'lt': lt,
    if (lte != null) 'lte': lte,
  };
}

/// Server-side filters that narrow the set of returned transactions.
///
/// Every filter is optional; supplying more than one combines them with AND
/// semantics.
class GetTransactionsForAddressFilters {
  /// Creates a filters object.
  const GetTransactionsForAddressFilters({
    this.blockTime,
    this.signature,
    this.slot,
    this.status,
    this.tokenAccounts,
  });

  /// Restrict results to a range of block times.
  final GetTransactionsForAddressComparison? blockTime;

  /// Restrict results to a range of signature orderings.
  final GetTransactionsForAddressComparison? signature;

  /// Restrict results to a range of slots.
  final GetTransactionsForAddressComparison? slot;

  /// Restrict results by execution status.
  ///
  /// - `'any'` returns both succeeded and failed transactions.
  /// - `'succeeded'` returns only transactions that did not error.
  /// - `'failed'` returns only transactions that errored.
  final String? status;

  /// Control whether activity on token accounts owned by the queried address
  /// is included.
  ///
  /// - `'none'` returns only transactions that reference the address directly.
  /// - `'balanceChanged'` additionally returns transactions that changed the
  ///   balance of a token account owned by the address.
  /// - `'all'` additionally returns every transaction that references a token
  ///   account owned by the address.
  final String? tokenAccounts;

  /// Converts this filters object to a JSON-RPC map.
  Map<String, Object?> toJson() => {
    if (blockTime != null) 'blockTime': blockTime!.toJson(),
    if (signature != null) 'signature': signature!.toJson(),
    if (slot != null) 'slot': slot!.toJson(),
    if (status != null) 'status': status,
    if (tokenAccounts != null) 'tokenAccounts': tokenAccounts,
  };
}

/// Configuration for the `getTransactionsForAddress` RPC method.
class GetTransactionsForAddressConfig {
  /// Creates a new [GetTransactionsForAddressConfig].
  const GetTransactionsForAddressConfig({
    this.commitment,
    this.filters,
    this.limit,
    this.minContextSlot,
    this.paginationToken,
    this.sortOrder,
    this.encoding,
    this.maxSupportedTransactionVersion,
    this.transactionDetails,
  });

  /// Fetch transactions as of the highest slot that has reached this level of
  /// commitment. The `'processed'` commitment is not supported by this method.
  final Commitment? commitment;

  /// Optional server-side filters that narrow the set of returned
  /// transactions.
  final GetTransactionsForAddressFilters? filters;

  /// Maximum number of results to return.
  ///
  /// The server caps this value at 1000 when [transactionDetails] is
  /// `'signatures'`, and at 100 when it is `'full'`.
  final int? limit;

  /// Prevents accessing stale data by enforcing that the RPC node has
  /// processed transactions up to this slot.
  final BigInt? minContextSlot;

  /// A cursor returned as `paginationToken` by a previous response, used to
  /// continue scanning from where that response left off.
  final String? paginationToken;

  /// The order in which transactions are returned, sorted by slot and then by
  /// position within the block: `'desc'` (newest first) or `'asc'` (oldest
  /// first).
  final String? sortOrder;

  /// Determines how each transaction is encoded in the response.
  final TransactionEncoding? encoding;

  /// The newest transaction version the caller wants to receive.
  ///
  /// When not supplied, only legacy transactions are returned and no
  /// `version` property is present in the response.
  final int? maxSupportedTransactionVersion;

  /// Whether to return only signatures (`'signatures'`) or full transactions
  /// (`'full'`).
  final String? transactionDetails;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (filters != null) json['filters'] = filters!.toJson();
    if (limit != null) json['limit'] = limit;
    if (minContextSlot != null) json['minContextSlot'] = minContextSlot;
    if (paginationToken != null) json['paginationToken'] = paginationToken;
    if (sortOrder != null) json['sortOrder'] = sortOrder;
    if (encoding != null) json['encoding'] = encoding!.toJson();
    if (maxSupportedTransactionVersion != null) {
      json['maxSupportedTransactionVersion'] =
          maxSupportedTransactionVersion;
    }
    if (transactionDetails != null) {
      json['transactionDetails'] = transactionDetails;
    }
    return json;
  }
}

/// Builds the JSON-RPC params list for `getTransactionsForAddress`.
List<Object?> getTransactionsForAddressParams(
  Address address, [
  GetTransactionsForAddressConfig? config,
]) {
  return [address.value, if (config != null) config.toJson()];
}
