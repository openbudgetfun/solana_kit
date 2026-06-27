import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<CompressedAccountProof> zkGetCompressedAccountProof(
  JsonRpcClient rpcClient,
  GetCompressedAccountProofRequest request,
) async {
  final result = await rpcClient.call(
    'getCompressedAccountProof',
    request.toJson(),
  );
  return CompressedAccountProof.fromJson(result! as Map<String, Object?>);
}
