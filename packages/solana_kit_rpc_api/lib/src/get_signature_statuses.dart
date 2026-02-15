import 'package:solana_kit_keys/solana_kit_keys.dart';

/// Configuration for the `getSignatureStatuses` RPC method.
class GetSignatureStatusesConfig {
  /// Creates a new [GetSignatureStatusesConfig].
  const GetSignatureStatusesConfig({this.searchTransactionHistory});

  /// When `true`, search into local block storage then archival storage.
  final bool? searchTransactionHistory;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (searchTransactionHistory != null) {
      json['searchTransactionHistory'] = searchTransactionHistory;
    }
    return json;
  }
}

/// Builds the JSON-RPC params list for `getSignatureStatuses`.
List<Object?> getSignatureStatusesParams(
  List<Signature> signatures, [
  GetSignatureStatusesConfig? config,
]) {
  return [
    [for (final sig in signatures) sig.value],
    if (config != null) config.toJson(),
  ];
}
