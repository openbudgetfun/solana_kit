import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

/// Returns compression signatures for the given owner address.
Future<CompressedSignatureList> zkGetCompressionSignaturesForOwner(
  JsonRpcClient rpcClient,
  GetCompressionSignaturesForOwnerRequest request,
) async {
  final result = await rpcClient.call(
    'getCompressionSignaturesForOwner',
    request.toJson(),
  );
  return CompressedSignatureList.fromJson(result! as Map<String, Object?>);
}
