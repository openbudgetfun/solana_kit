import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `isBlockhashValid` RPC method.
class IsBlockhashValidConfig {
  /// Creates a new [IsBlockhashValidConfig].
  const IsBlockhashValidConfig({this.commitment, this.minContextSlot});

  /// Evaluate whether the blockhash is valid as of the highest slot that
  /// has reached this level of commitment.
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

/// Builds the JSON-RPC params list for `isBlockhashValid`.
List<Object?> isBlockhashValidParams(
  Blockhash blockhash, [
  IsBlockhashValidConfig? config,
]) {
  return [blockhash.value, if (config != null) config.toJson()];
}
