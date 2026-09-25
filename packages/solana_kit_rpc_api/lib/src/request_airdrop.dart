import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `requestAirdrop` RPC method.
class RequestAirdropConfig {
  /// Creates a new [RequestAirdropConfig].
  const RequestAirdropConfig({this.commitment});

  /// Evaluate the request as of the highest slot that has reached this level
  /// of commitment.
  final Commitment? commitment;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    return json;
  }
}

/// Builds the JSON-RPC params list for `requestAirdrop`.
List<Object?> requestAirdropParams(
  Address recipientAccount,
  Lamports lamports, [
  RequestAirdropConfig? config,
]) {
  return [
    recipientAccount.value,
    lamports.value,
    if (config != null) config.toJson(),
  ];
}
