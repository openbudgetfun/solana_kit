import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `getAssetProof` DAS API method.
///
/// Returns the Merkle proof for a compressed asset identified by its id.
Future<AssetProof> dasGetAssetProof(
  JsonRpcClient rpcClient,
  GetAssetProofRequest request,
) async {
  final result = await rpcClient.call('getAssetProof', request.toJson());
  return AssetProof.fromJson(result! as Map<String, Object?>);
}
