import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getStakeMinimumDelegation` RPC method.
class GetStakeMinimumDelegationConfig {
  /// Creates a new [GetStakeMinimumDelegationConfig].
  const GetStakeMinimumDelegationConfig({this.commitment});

  /// Fetch the minimum delegation as of the highest slot that has reached
  /// this level of commitment.
  final Commitment? commitment;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getStakeMinimumDelegation`.
List<Object?> getStakeMinimumDelegationParams([
  GetStakeMinimumDelegationConfig? config,
]) {
  return [if (config != null) config.toJson()];
}
