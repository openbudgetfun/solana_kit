import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getBlocks` RPC method.
class GetBlocksConfig {
  /// Creates a new [GetBlocksConfig].
  const GetBlocksConfig({this.commitment});

  /// Include only blocks at slots that have reached at least this level of
  /// commitment. Note: `processed` is not supported.
  final Commitment? commitment;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getBlocks`.
List<Object?> getBlocksParams(
  Slot startSlotInclusive, [
  Slot? endSlotInclusive,
  GetBlocksConfig? config,
]) {
  return [
    startSlotInclusive,
    if (endSlotInclusive != null) endSlotInclusive,
    if (config != null) config.toJson(),
  ];
}
