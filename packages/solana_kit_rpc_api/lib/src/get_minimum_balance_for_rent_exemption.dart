import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getMinimumBalanceForRentExemption` RPC method.
class GetMinimumBalanceForRentExemptionConfig {
  /// Creates a new [GetMinimumBalanceForRentExemptionConfig].
  const GetMinimumBalanceForRentExemptionConfig({this.commitment});

  /// Return the minimum balance as of the highest slot that has reached this
  /// level of commitment.
  final Commitment? commitment;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getMinimumBalanceForRentExemption`.
List<Object?> getMinimumBalanceForRentExemptionParams(
  BigInt size, [
  GetMinimumBalanceForRentExemptionConfig? config,
]) {
  return [size, if (config != null) config.toJson()];
}
