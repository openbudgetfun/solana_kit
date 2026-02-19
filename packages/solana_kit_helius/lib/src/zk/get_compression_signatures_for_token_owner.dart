import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<CompressedSignatureList> zkGetCompressionSignaturesForTokenOwner(
  JsonRpcClient rpcClient,
  GetCompressionSignaturesForTokenOwnerRequest request,
) async {
  final result = await rpcClient.call(
    'getCompressionSignaturesForTokenOwner',
    request.toJson(),
  );
  return CompressedSignatureList.fromJson(result! as Map<String, Object?>);
}
