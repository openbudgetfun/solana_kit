// ignore_for_file: public_member_api_docs
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';

Future<int> zkGetIndexerSlot(JsonRpcClient rpcClient) async {
  final result = await rpcClient.call('getIndexerSlot');
  return result! as int;
}
