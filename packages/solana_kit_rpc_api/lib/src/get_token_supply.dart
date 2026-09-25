import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getTokenSupply` RPC method.
class GetTokenSupplyConfig {
  /// Creates a new [GetTokenSupplyConfig].
  const GetTokenSupplyConfig({this.commitment});

  /// Fetch the supply as of the highest slot that has reached this level
  /// of commitment.
  final Commitment? commitment;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getTokenSupply`.
List<Object?> getTokenSupplyParams(
  Address tokenMint, [
  GetTokenSupplyConfig? config,
]) {
  return [tokenMint.value, if (config != null) config.toJson()];
}
