import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getInflationGovernor` RPC method.
class GetInflationGovernorConfig {
  /// Creates a new [GetInflationGovernorConfig].
  const GetInflationGovernorConfig({this.commitment});

  /// Return the inflation governor as of the highest slot that has reached
  /// this level of commitment.
  final Commitment? commitment;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getInflationGovernor`.
List<Object?> getInflationGovernorParams([GetInflationGovernorConfig? config]) {
  return [if (config != null) config.toJson()];
}
