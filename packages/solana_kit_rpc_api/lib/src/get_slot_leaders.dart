import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Builds the JSON-RPC params list for `getSlotLeaders`.
List<Object?> getSlotLeadersParams(Slot startSlotInclusive, int limit) {
  return [startSlotInclusive, limit];
}
