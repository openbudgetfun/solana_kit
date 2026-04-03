import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// A slot range for block production queries.
class SlotRange {
  /// Creates a new [SlotRange].
  const SlotRange({required this.firstSlot, this.lastSlot});

  /// First slot to return block production information for.
  final Slot firstSlot;

  /// Last slot to return block production information for.
  final Slot? lastSlot;

  /// Converts this to a JSON map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{'firstSlot': firstSlot};
    if (lastSlot != null) json['lastSlot'] = lastSlot;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlotRange &&
          runtimeType == other.runtimeType &&
          firstSlot == other.firstSlot &&
          lastSlot == other.lastSlot;

  @override
  int get hashCode => Object.hash(runtimeType, firstSlot, lastSlot);

  @override
  String toString() =>
      'SlotRange(firstSlot: $firstSlot, lastSlot: $lastSlot)';
}

/// Configuration for the `getBlockProduction` RPC method.
class GetBlockProductionConfig {
  /// Creates a new [GetBlockProductionConfig].
  const GetBlockProductionConfig({this.commitment, this.identity, this.range});

  /// Fetch block production as of the highest slot that has reached this
  /// level of commitment.
  final Commitment? commitment;

  /// Only return results for this validator identity.
  final Address? identity;

  /// Slot range to return block production for (inclusive).
  final SlotRange? range;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (identity != null) json['identity'] = identity!.value;
    if (range != null) json['range'] = range!.toJson();
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetBlockProductionConfig &&
          runtimeType == other.runtimeType &&
          commitment == other.commitment &&
          identity == other.identity &&
          range == other.range;

  @override
  int get hashCode => Object.hash(runtimeType, commitment, identity, range);

  @override
  String toString() =>
      'GetBlockProductionConfig(commitment: $commitment, identity: $identity, '
      'range: $range)';
}

/// Builds the JSON-RPC params list for `getBlockProduction`.
List<Object?> getBlockProductionParams([GetBlockProductionConfig? config]) {
  return [if (config != null) config.toJson()];
}
