import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<CompressedTokenAccountList> zkGetCompressedTokenAccountsByOwner(
  JsonRpcClient rpcClient,
  GetCompressedTokenAccountsByOwnerRequest request,
) async {
  final result = await rpcClient.call(
    'getCompressedTokenAccountsByOwner',
    request.toJson(),
  );
  return CompressedTokenAccountList.fromJson(result! as Map<String, Object?>);
}
