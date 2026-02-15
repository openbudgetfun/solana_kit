import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Builds the JSON-RPC params list for `getBlockTime`.
List<Object?> getBlockTimeParams(Slot blockNumber) {
  return [blockNumber];
}
