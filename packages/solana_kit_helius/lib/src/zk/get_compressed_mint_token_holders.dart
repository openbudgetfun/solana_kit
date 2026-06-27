import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<CompressedTokenAccountList> zkGetCompressedMintTokenHolders(
  JsonRpcClient rpcClient,
  GetCompressedMintTokenHoldersRequest request,
) async {
  final result = await rpcClient.call(
    'getCompressedMintTokenHolders',
    request.toJson(),
  );
  return CompressedTokenAccountList.fromJson(result! as Map<String, Object?>);
}
