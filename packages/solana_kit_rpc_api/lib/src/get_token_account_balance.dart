import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getTokenAccountBalance` RPC method.
class GetTokenAccountBalanceConfig {
  /// Creates a new [GetTokenAccountBalanceConfig].
  const GetTokenAccountBalanceConfig({this.commitment});

  /// Fetch the balance as of the highest slot that has reached this level
  /// of commitment.
  final Commitment? commitment;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getTokenAccountBalance`.
List<Object?> getTokenAccountBalanceParams(
  Address address, [
  GetTokenAccountBalanceConfig? config,
]) {
  return [address.value, if (config != null) config.toJson()];
}
