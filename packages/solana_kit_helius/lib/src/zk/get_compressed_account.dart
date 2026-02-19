import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<CompressedAccount> zkGetCompressedAccount(
  JsonRpcClient rpcClient,
  GetCompressedAccountRequest request,
) async {
  final result = await rpcClient.call('getCompressedAccount', request.toJson());
  return CompressedAccount.fromJson(result! as Map<String, Object?>);
}
