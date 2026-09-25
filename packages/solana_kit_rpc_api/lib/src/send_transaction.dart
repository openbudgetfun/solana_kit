import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `sendTransaction` RPC method.
class SendTransactionConfig {
  /// Creates a new [SendTransactionConfig].
  const SendTransactionConfig({
    this.encoding,
    this.maxRetries,
    this.minContextSlot,
    this.preflightCommitment,
    this.skipPreflight,
  });

  /// The encoding of the transaction. Defaults to `'base64'`.
  final WireTransactionEncoding? encoding;

  /// Maximum number of times for the RPC node to retry sending the
  /// transaction to the leader.
  final BigInt? maxRetries;

  /// Prevents accessing stale data by enforcing that the RPC node has
  /// processed transactions up to this slot.
  final Slot? minContextSlot;

  /// Simulate the transaction as of the highest slot that has reached this
  /// level of commitment.
  final Commitment? preflightCommitment;

  /// Whether to skip preflight checks. Defaults to `false`.
  final bool? skipPreflight;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (encoding != null) json['encoding'] = encoding!.toJson();
    if (maxRetries != null) json['maxRetries'] = maxRetries;
    if (minContextSlot != null) json['minContextSlot'] = minContextSlot;
    if (preflightCommitment != null) {
      json['preflightCommitment'] = preflightCommitment!.name;
    }
    if (skipPreflight != null) json['skipPreflight'] = skipPreflight;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendTransactionConfig &&
          runtimeType == other.runtimeType &&
          encoding == other.encoding &&
          maxRetries == other.maxRetries &&
          minContextSlot == other.minContextSlot &&
          preflightCommitment == other.preflightCommitment &&
          skipPreflight == other.skipPreflight;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    encoding,
    maxRetries,
    minContextSlot,
    preflightCommitment,
    skipPreflight,
  );

  @override
  String toString() =>
      'SendTransactionConfig(encoding: $encoding, maxRetries: $maxRetries, '
      'minContextSlot: $minContextSlot, '
      'preflightCommitment: $preflightCommitment, '
      'skipPreflight: $skipPreflight)';
}

/// Builds the JSON-RPC params list for `sendTransaction`.
List<Object?> sendTransactionParams(
  String base64EncodedWireTransaction, [
  SendTransactionConfig? config,
]) {
  return [base64EncodedWireTransaction, if (config != null) config.toJson()];
}
