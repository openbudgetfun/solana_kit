import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';

/// Returns the current slot the indexer has synced up to.
Future<int> zkGetIndexerSlot(JsonRpcClient rpcClient) async {
  final result = await rpcClient.call('getIndexerSlot');
  return result! as int;
}
