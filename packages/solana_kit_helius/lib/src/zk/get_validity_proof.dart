import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

/// Returns a validity proof for the given hashes.
///
/// The response carries the Groth16 components as raw byte arrays plus the
/// Merkle tree context (upstream v4.0.0 #397).
Future<GetValidityProofResponse> zkGetValidityProof(
  JsonRpcClient rpcClient,
  GetValidityProofRequest request,
) async {
  final result = await rpcClient.call('getValidityProof', request.toJson());

  return GetValidityProofResponse.fromJson(result! as Map<String, Object?>);
}
