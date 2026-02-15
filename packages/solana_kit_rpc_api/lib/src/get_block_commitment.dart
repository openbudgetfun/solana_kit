import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Builds the JSON-RPC params list for `getBlockCommitment`.
List<Object?> getBlockCommitmentParams(Slot slot) {
  return [slot];
}
