import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Accounts configuration for `simulateTransaction`.
class SimulateTransactionAccountsConfig {
  /// Creates a new [SimulateTransactionAccountsConfig].
  const SimulateTransactionAccountsConfig({
    required this.addresses,
    this.encoding,
  });

  /// An array of accounts to return.
  final List<Address> addresses;

  /// Encoding for returned account data.
  final AccountEncoding? encoding;

  /// Converts to a JSON map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{
      'addresses': [for (final address in addresses) address.value],
    };
    if (encoding != null) json['encoding'] = encoding!.toJson();
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulateTransactionAccountsConfig &&
          runtimeType == other.runtimeType &&
          _listEquals(addresses, other.addresses) &&
          encoding == other.encoding;

  @override
  int get hashCode =>
      Object.hash(runtimeType, Object.hashAll(addresses), encoding);

  @override
  String toString() =>
      'SimulateTransactionAccountsConfig(addresses: $addresses, '
      'encoding: $encoding)';
}

/// Configuration for the `simulateTransaction` RPC method.
class SimulateTransactionConfig {
  /// Creates a new [SimulateTransactionConfig].
  const SimulateTransactionConfig({
    this.accounts,
    this.commitment,
    this.encoding,
    this.innerInstructions,
    this.minContextSlot,
    this.replaceRecentBlockhash,
    this.sigVerify,
  });

  /// Configuration for accounts to return in the simulation result.
  final SimulateTransactionAccountsConfig? accounts;

  /// Simulate the transaction as of the highest slot that has reached this
  /// level of commitment.
  final Commitment? commitment;

  /// The encoding of the transaction. Defaults to `'base64'`.
  final WireTransactionEncoding? encoding;

  /// If `true` the response will include inner instructions.
  final bool? innerInstructions;

  /// Prevents accessing stale data.
  final Slot? minContextSlot;

  /// If `true` the transaction recent blockhash will be replaced with the
  /// most recent blockhash. Conflicts with [sigVerify].
  final bool? replaceRecentBlockhash;

  /// If `true` the transaction signatures will be verified. Conflicts with
  /// [replaceRecentBlockhash].
  final bool? sigVerify;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (accounts != null) json['accounts'] = accounts!.toJson();
    if (commitment != null) json['commitment'] = commitment!.name;
    if (encoding != null) json['encoding'] = encoding!.toJson();
    if (innerInstructions != null) {
      json['innerInstructions'] = innerInstructions;
    }
    if (minContextSlot != null) json['minContextSlot'] = minContextSlot;
    if (replaceRecentBlockhash != null) {
      json['replaceRecentBlockhash'] = replaceRecentBlockhash;
    }
    if (sigVerify != null) json['sigVerify'] = sigVerify;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulateTransactionConfig &&
          runtimeType == other.runtimeType &&
          accounts == other.accounts &&
          commitment == other.commitment &&
          encoding == other.encoding &&
          innerInstructions == other.innerInstructions &&
          minContextSlot == other.minContextSlot &&
          replaceRecentBlockhash == other.replaceRecentBlockhash &&
          sigVerify == other.sigVerify;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    accounts,
    commitment,
    encoding,
    innerInstructions,
    minContextSlot,
    replaceRecentBlockhash,
    sigVerify,
  );

  @override
  String toString() =>
      'SimulateTransactionConfig(accounts: $accounts, commitment: $commitment, '
      'encoding: $encoding, innerInstructions: $innerInstructions, '
      'minContextSlot: $minContextSlot, '
      'replaceRecentBlockhash: $replaceRecentBlockhash, sigVerify: $sigVerify)';
}

/// Addresses loaded from address lookup tables during simulation.
class SimulateTransactionLoadedAddresses {
  /// Creates loaded address metadata for a simulated transaction.
  const SimulateTransactionLoadedAddresses({
    required this.readonly,
    required this.writable,
  });

  /// Ordered list of read-only loaded addresses.
  final List<Address> readonly;

  /// Ordered list of writable loaded addresses.
  final List<Address> writable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulateTransactionLoadedAddresses &&
          runtimeType == other.runtimeType &&
          _listEquals(readonly, other.readonly) &&
          _listEquals(writable, other.writable);

  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(readonly),
    Object.hashAll(writable),
  );

  @override
  String toString() =>
      'SimulateTransactionLoadedAddresses(readonly: $readonly, writable: $writable)';
}

/// Result value returned by `simulateTransaction`.
class SimulateTransactionResult {
  /// Creates a simulated transaction result.
  const SimulateTransactionResult({
    required this.err,
    required this.fee,
    required this.loadedAddresses,
    required this.logs,
    required this.postBalances,
    required this.postTokenBalances,
    required this.preBalances,
    required this.preTokenBalances,
    required this.returnData,
    this.loadedAccountsDataSize,
    this.unitsConsumed,
  });

  /// Error if transaction failed, `null` if simulation succeeded.
  final TransactionError? err;

  /// The fee the transaction would have paid, or `null` when unavailable.
  final Lamports? fee;

  /// Number of bytes of all accounts loaded by this transaction.
  final int? loadedAccountsDataSize;

  /// Addresses loaded from address lookup tables, or `null` when unavailable.
  final SimulateTransactionLoadedAddresses? loadedAddresses;

  /// Log messages emitted during execution, or `null` when execution did not start.
  final List<String>? logs;

  /// Lamport balances for each account after simulation.
  final List<Lamports>? postBalances;

  /// Token balances after simulation.
  final List<TokenBalance>? postTokenBalances;

  /// Lamport balances for each account before simulation.
  final List<Lamports>? preBalances;

  /// Token balances before simulation.
  final List<TokenBalance>? preTokenBalances;

  /// Most recent return data generated by an instruction.
  final ReturnData? returnData;

  /// Compute budget units consumed during simulation.
  final BigInt? unitsConsumed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulateTransactionResult &&
          runtimeType == other.runtimeType &&
          err == other.err &&
          fee == other.fee &&
          loadedAccountsDataSize == other.loadedAccountsDataSize &&
          loadedAddresses == other.loadedAddresses &&
          _nullableListEquals(logs, other.logs) &&
          _nullableListEquals(postBalances, other.postBalances) &&
          _nullableListEquals(postTokenBalances, other.postTokenBalances) &&
          _nullableListEquals(preBalances, other.preBalances) &&
          _nullableListEquals(preTokenBalances, other.preTokenBalances) &&
          returnData == other.returnData &&
          unitsConsumed == other.unitsConsumed;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    err,
    fee,
    loadedAccountsDataSize,
    loadedAddresses,
    logs == null ? null : Object.hashAll(logs!),
    postBalances == null ? null : Object.hashAll(postBalances!),
    postTokenBalances == null ? null : Object.hashAll(postTokenBalances!),
    preBalances == null ? null : Object.hashAll(preBalances!),
    preTokenBalances == null ? null : Object.hashAll(preTokenBalances!),
    returnData,
    unitsConsumed,
  );

  @override
  String toString() =>
      'SimulateTransactionResult(err: $err, fee: $fee, '
      'loadedAccountsDataSize: $loadedAccountsDataSize, '
      'loadedAddresses: $loadedAddresses, logs: $logs, '
      'postBalances: $postBalances, postTokenBalances: $postTokenBalances, '
      'preBalances: $preBalances, preTokenBalances: $preTokenBalances, '
      'returnData: $returnData, unitsConsumed: $unitsConsumed)';
}

/// Builds the JSON-RPC params list for `simulateTransaction`.
List<Object?> simulateTransactionParams(
  String encodedTransaction, [
  SimulateTransactionConfig? config,
]) {
  return [encodedTransaction, if (config != null) config.toJson()];
}

bool _nullableListEquals<T>(List<T>? a, List<T>? b) {
  if (a == null || b == null) return a == b;
  return _listEquals(a, b);
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
