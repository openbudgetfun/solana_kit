import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getTokenLargestAccounts` RPC method.
class GetTokenLargestAccountsConfig {
  /// Creates a new [GetTokenLargestAccountsConfig].
  const GetTokenLargestAccountsConfig({this.commitment});

  /// Fetch the largest accounts as of the highest slot that has reached this
  /// level of commitment.
  final Commitment? commitment;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getTokenLargestAccounts`.
List<Object?> getTokenLargestAccountsParams(
  Address tokenMint, [
  GetTokenLargestAccountsConfig? config,
]) {
  return [tokenMint.value, if (config != null) config.toJson()];
}
