import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `getAssetProofBatch` DAS API method.
///
/// Returns Merkle proofs for multiple compressed assets in a single request.
/// The returned map is keyed by asset ID.
Future<Map<String, AssetProof>> dasGetAssetProofBatch(
  JsonRpcClient rpcClient,
  GetAssetProofBatchRequest request,
) async {
  final result = await rpcClient.call('getAssetProofBatch', request.toJson());
  final map = result! as Map<String, Object?>;
  return map.map(
    (key, value) =>
        MapEntry(key, AssetProof.fromJson(value! as Map<String, Object?>)),
  );
}
