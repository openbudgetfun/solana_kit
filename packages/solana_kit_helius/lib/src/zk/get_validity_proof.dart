import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

/// Returns a validity proof for the given hashes.
Future<ValidityProof> zkGetValidityProof(
  JsonRpcClient rpcClient,
  GetValidityProofRequest request,
) async {
  final result = await rpcClient.call('getValidityProof', request.toJson());
  return ValidityProof.fromJson(result! as Map<String, Object?>);
}
