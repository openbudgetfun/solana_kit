import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getBlock` RPC method.
class GetBlockConfig {
  /// Creates a new [GetBlockConfig].
  const GetBlockConfig({
    this.commitment,
    this.encoding,
    this.maxSupportedTransactionVersion,
    this.rewards,
    this.transactionDetails,
  });

  /// Fetch blocks from slots that have reached at least this level of
  /// commitment. Note: `processed` is not supported for this method.
  final Commitment? commitment;

  /// Determines how the transaction property should be encoded.
  /// Defaults to `'json'`.
  final TransactionEncoding? encoding;

  /// The newest transaction version the caller wants to receive.
  ///
  /// When not supplied, only legacy transactions are returned.
  /// Set to `0` for version 0 transactions.
  final int? maxSupportedTransactionVersion;

  /// Whether to include block rewards. Defaults to `true`.
  final bool? rewards;

  /// Level of transaction detail to include.
  ///
  /// One of `'accounts'`, `'full'`, `'none'`, or `'signatures'`.
  /// Defaults to `'full'`.
  final String? transactionDetails;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (encoding != null) json['encoding'] = encoding!.toJson();
    if (maxSupportedTransactionVersion != null) {
      json['maxSupportedTransactionVersion'] = maxSupportedTransactionVersion;
    }
    if (rewards != null) json['rewards'] = rewards;
    if (transactionDetails != null) {
      json['transactionDetails'] = transactionDetails;
    }
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetBlockConfig &&
          runtimeType == other.runtimeType &&
          commitment == other.commitment &&
          encoding == other.encoding &&
          maxSupportedTransactionVersion == other.maxSupportedTransactionVersion &&
          rewards == other.rewards &&
          transactionDetails == other.transactionDetails;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    commitment,
    encoding,
    maxSupportedTransactionVersion,
    rewards,
    transactionDetails,
  );

  @override
  String toString() =>
      'GetBlockConfig(commitment: $commitment, encoding: $encoding, '
      'maxSupportedTransactionVersion: $maxSupportedTransactionVersion, '
      'rewards: $rewards, transactionDetails: $transactionDetails)';
}

/// Builds the JSON-RPC params list for `getBlock`.
List<Object?> getBlockParams(Slot slot, [GetBlockConfig? config]) {
  return [slot, if (config != null) config.toJson()];
}
