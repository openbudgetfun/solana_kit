import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `getAssetBatch` DAS API method.
///
/// Returns metadata for multiple digital assets in a single request.
Future<List<HeliusAsset>> dasGetAssetBatch(
  JsonRpcClient rpcClient,
  GetAssetBatchRequest request,
) async {
  final result = await rpcClient.call('getAssetBatch', request.toJson());
  final list = result! as List<Object?>;
  return list.cast<Map<String, Object?>>().map(HeliusAsset.fromJson).toList();
}
