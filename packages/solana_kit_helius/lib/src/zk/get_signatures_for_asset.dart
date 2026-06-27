import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<CompressedSignatureList> zkGetSignaturesForAsset(
  JsonRpcClient rpcClient,
  GetZkSignaturesForAssetRequest request,
) async {
  final result = await rpcClient.call(
    'getSignaturesForAsset',
    request.toJson(),
  );
  return CompressedSignatureList.fromJson(result! as Map<String, Object?>);
}
