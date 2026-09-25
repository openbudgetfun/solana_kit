import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getInflationReward` RPC method.
class GetInflationRewardConfig {
  /// Creates a new [GetInflationRewardConfig].
  const GetInflationRewardConfig({
    this.commitment,
    this.epoch,
    this.minContextSlot,
  });

  /// Fetch the inflation reward details as of the highest slot that has
  /// reached this level of commitment.
  final Commitment? commitment;

  /// An epoch for which the reward occurs.
  final BigInt? epoch;

  /// Prevents accessing stale data by enforcing that the RPC node has
  /// processed transactions up to this slot.
  final Slot? minContextSlot;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (epoch != null) json['epoch'] = epoch;
    if (minContextSlot != null) json['minContextSlot'] = minContextSlot;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getInflationReward`.
List<Object?> getInflationRewardParams(
  List<Address> addresses, [
  GetInflationRewardConfig? config,
]) {
  return [
    [for (final address in addresses) address.value],
    if (config != null) config.toJson(),
  ];
}
