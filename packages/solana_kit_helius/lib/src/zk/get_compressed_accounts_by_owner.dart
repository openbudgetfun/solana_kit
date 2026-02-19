import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<CompressedAccountList> zkGetCompressedAccountsByOwner(
  JsonRpcClient rpcClient,
  GetCompressedAccountsByOwnerRequest request,
) async {
  final result = await rpcClient.call(
    'getCompressedAccountsByOwner',
    request.toJson(),
  );
  return CompressedAccountList.fromJson(result! as Map<String, Object?>);
}
