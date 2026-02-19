import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<List<CompressedAccountProof>> zkGetMultipleCompressedAccountProofs(
  JsonRpcClient rpcClient,
  GetMultipleCompressedAccountProofsRequest request,
) async {
  final result = await rpcClient.call(
    'getMultipleCompressedAccountProofs',
    request.toJson(),
  );
  final list = result! as List<Object?>;
  return list
      .cast<Map<String, Object?>>()
      .map(CompressedAccountProof.fromJson)
      .toList();
}
