import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `signatureSubscribe` RPC subscription method.
///
/// Subscribe to receive a notification when the transaction identified by
/// the given signature reaches the specified level of commitment.
class SignatureNotificationsConfig {
  /// Creates a new [SignatureNotificationsConfig].
  const SignatureNotificationsConfig({
    this.commitment,
    this.enableReceivedNotification,
  });

  /// Get notified when the transaction with the specified signature has
  /// reached this level of commitment.
  final Commitment? commitment;

  /// Whether or not to subscribe for notifications when signatures are
  /// received by the RPC, in addition to when they are processed.
  ///
  /// Defaults to `false`.
  final bool? enableReceivedNotification;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (enableReceivedNotification != null) {
      json['enableReceivedNotification'] = enableReceivedNotification;
    }
    return json;
  }
}

/// Builds the JSON-RPC params list for `signatureSubscribe`.
List<Object?> signatureNotificationsParams(
  Signature signature, [
  SignatureNotificationsConfig? config,
]) {
  return [signature.value, if (config != null) config.toJson()];
}
