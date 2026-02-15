import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getTransaction` RPC method.
class GetTransactionConfig {
  /// Creates a new [GetTransactionConfig].
  const GetTransactionConfig({
    this.commitment,
    this.encoding,
    this.maxSupportedTransactionVersion,
  });

  /// Fetch the transaction details as of the highest slot that has reached
  /// this level of commitment.
  final Commitment? commitment;

  /// Determines how the transaction should be encoded in the response.
  ///
  /// One of `'base58'`, `'base64'`, `'json'`, or `'jsonParsed'`.
  final String? encoding;

  /// The newest transaction version the caller wants to receive.
  ///
  /// When not supplied, only legacy transactions are returned.
  final int? maxSupportedTransactionVersion;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (encoding != null) json['encoding'] = encoding;
    if (maxSupportedTransactionVersion != null) {
      json['maxSupportedTransactionVersion'] = maxSupportedTransactionVersion;
    }
    return json;
  }
}

/// Builds the JSON-RPC params list for `getTransaction`.
List<Object?> getTransactionParams(
  Signature signature, [
  GetTransactionConfig? config,
]) {
  return [signature.value, if (config != null) config.toJson()];
}
