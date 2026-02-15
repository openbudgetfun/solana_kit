import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getSupply` RPC method.
class GetSupplyConfig {
  /// Creates a new [GetSupplyConfig].
  const GetSupplyConfig({
    this.commitment,
    this.excludeNonCirculatingAccountsList,
  });

  /// Fetch the supply as of the highest slot that has reached this level
  /// of commitment.
  final Commitment? commitment;

  /// Whether to exclude the list of non-circulating accounts.
  final bool? excludeNonCirculatingAccountsList;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (excludeNonCirculatingAccountsList != null) {
      json['excludeNonCirculatingAccountsList'] =
          excludeNonCirculatingAccountsList;
    }
    return json;
  }
}

/// Builds the JSON-RPC params list for `getSupply`.
List<Object?> getSupplyParams([GetSupplyConfig? config]) {
  return [if (config != null) config.toJson()];
}
