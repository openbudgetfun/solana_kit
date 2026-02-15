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
  final String? encoding;

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
    if (encoding != null) json['encoding'] = encoding;
    if (maxRetries != null) json['maxRetries'] = maxRetries;
    if (minContextSlot != null) json['minContextSlot'] = minContextSlot;
    if (preflightCommitment != null) {
      json['preflightCommitment'] = preflightCommitment!.name;
    }
    if (skipPreflight != null) json['skipPreflight'] = skipPreflight;
    return json;
  }
}

/// Builds the JSON-RPC params list for `sendTransaction`.
List<Object?> sendTransactionParams(
  String base64EncodedWireTransaction, [
  SendTransactionConfig? config,
]) {
  return [base64EncodedWireTransaction, if (config != null) config.toJson()];
}
