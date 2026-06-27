import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<CompressedSignatureList> zkGetCompressionSignaturesForAccount(
  JsonRpcClient rpcClient,
  GetCompressionSignaturesForAccountRequest request,
) async {
  final result = await rpcClient.call(
    'getCompressionSignaturesForAccount',
    request.toJson(),
  );
  return CompressedSignatureList.fromJson(result! as Map<String, Object?>);
}
