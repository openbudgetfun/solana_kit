import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `accountSubscribe` RPC subscription method.
///
/// Subscribe for notifications when there is a change in the lamports or data
/// of the account at the specified address.
class AccountNotificationsConfig {
  /// Creates a new [AccountNotificationsConfig].
  const AccountNotificationsConfig({this.commitment, this.encoding});

  /// Get notified when a modification to an account has reached this level
  /// of commitment.
  final Commitment? commitment;

  /// Determines how the account data should be encoded in the notification.
  ///
  /// One of `'base58'`, `'base64'`, `'base64+zstd'`, or `'jsonParsed'`.
  final String? encoding;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (encoding != null) json['encoding'] = encoding;
    return json;
  }
}

/// Builds the JSON-RPC params list for `accountSubscribe`.
List<Object?> accountNotificationsParams(
  Address address, [
  AccountNotificationsConfig? config,
]) {
  return [address.value, if (config != null) config.toJson()];
}
