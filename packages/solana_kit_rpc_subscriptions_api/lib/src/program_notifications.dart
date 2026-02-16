import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `programSubscribe` RPC subscription method.
///
/// Subscribe for notifications when there is a change in the lamports or data
/// of any account owned by the program at the given address.
class ProgramNotificationsConfig {
  /// Creates a new [ProgramNotificationsConfig].
  const ProgramNotificationsConfig({
    this.commitment,
    this.encoding,
    this.filters,
  });

  /// Get notified when a modification to an account has reached this level
  /// of commitment.
  final Commitment? commitment;

  /// Determines how the account data should be encoded in the notification.
  ///
  /// One of `'base58'`, `'base64'`, `'base64+zstd'`, or `'jsonParsed'`.
  final String? encoding;

  /// Limits results to those that match all of these filters.
  ///
  /// You can specify up to 4 filters.
  final List<Object>? filters;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (encoding != null) json['encoding'] = encoding;
    if (filters != null) json['filters'] = filters;
    return json;
  }
}

/// Builds the JSON-RPC params list for `programSubscribe`.
List<Object?> programNotificationsParams(
  Address programId, [
  ProgramNotificationsConfig? config,
]) {
  return [programId.value, if (config != null) config.toJson()];
}
