import 'package:solana_kit_addresses/solana_kit_addresses.dart';
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
  ///
  /// One of `'base64'`, `'base64+zstd'`, or `'jsonParsed'`.
  final String? encoding;

  /// Converts to a JSON map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{
      'addresses': [for (final address in addresses) address.value],
    };
    if (encoding != null) json['encoding'] = encoding;
    return json;
  }
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
  final String? encoding;

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
    if (encoding != null) json['encoding'] = encoding;
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
}

/// Builds the JSON-RPC params list for `simulateTransaction`.
List<Object?> simulateTransactionParams(
  String encodedTransaction, [
  SimulateTransactionConfig? config,
]) {
  return [encodedTransaction, if (config != null) config.toJson()];
}
