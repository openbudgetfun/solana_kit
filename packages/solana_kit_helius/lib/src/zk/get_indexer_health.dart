import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<IndexerHealth> zkGetIndexerHealth(JsonRpcClient rpcClient) async {
  final result = await rpcClient.call('getIndexerHealth');
  return IndexerHealth.fromJson(result! as Map<String, Object?>);
}
