import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getBlocksWithLimit` RPC method.
class GetBlocksWithLimitConfig {
  /// Creates a new [GetBlocksWithLimitConfig].
  const GetBlocksWithLimitConfig({this.commitment});

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

/// Builds the JSON-RPC params list for `getBlocksWithLimit`.
List<Object?> getBlocksWithLimitParams(
  Slot startSlotInclusive,
  int limit, [
  GetBlocksWithLimitConfig? config,
]) {
  return [startSlotInclusive, limit, if (config != null) config.toJson()];
}
