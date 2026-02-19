import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<CompressedTokenAccountList> zkGetCompressedTokenAccountsByDelegate(
  JsonRpcClient rpcClient,
  GetCompressedTokenAccountsByDelegateRequest request,
) async {
  final result = await rpcClient.call(
    'getCompressedTokenAccountsByDelegate',
    request.toJson(),
  );
  return CompressedTokenAccountList.fromJson(result! as Map<String, Object?>);
}
