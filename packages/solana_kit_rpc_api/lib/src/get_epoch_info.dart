import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getEpochInfo` RPC method.
class GetEpochInfoConfig {
  /// Creates a new [GetEpochInfoConfig].
  const GetEpochInfoConfig({this.commitment, this.minContextSlot});

  /// Fetch epoch information as of the highest slot that has reached this
  /// level of commitment.
  final Commitment? commitment;

  /// Prevents accessing stale data by enforcing that the RPC node has
  /// processed transactions up to this slot.
  final Slot? minContextSlot;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (minContextSlot != null) json['minContextSlot'] = minContextSlot;
    return json;
  }
}

/// Response from the `getEpochInfo` RPC method.
class EpochInfo {
  /// Creates a new [EpochInfo].
  const EpochInfo({
    required this.absoluteSlot,
    required this.blockHeight,
    required this.epoch,
    required this.slotIndex,
    required this.slotsInEpoch,
    this.transactionCount,
  });

  /// The current slot.
  final Slot absoluteSlot;

  /// The current block height.
  final BigInt blockHeight;

  /// The current epoch.
  final BigInt epoch;

  /// The current slot relative to the start of the current epoch.
  final BigInt slotIndex;

  /// The number of slots in this epoch.
  final BigInt slotsInEpoch;

  /// Total number of transactions processed without error since genesis.
  final BigInt? transactionCount;
}

/// Builds the JSON-RPC params list for `getEpochInfo`.
List<Object?> getEpochInfoParams([GetEpochInfoConfig? config]) {
  return [if (config != null) config.toJson()];
}
