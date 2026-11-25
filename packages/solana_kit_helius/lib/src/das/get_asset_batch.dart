import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `getAssetBatch` DAS API method.
///
/// Returns one entry per requested id, in request order; an entry is null
/// when the id was not found (upstream v4.0.0 #410).
Future<List<HeliusAsset?>> dasGetAssetBatch(
  JsonRpcClient rpcClient,
  GetAssetBatchRequest request,
) async {
  final result = await rpcClient.call('getAssetBatch', request.toJson());
  final list = result! as List<Object?>;

  return [
    for (final entry in list)
      if (entry == null)
        null
      else
        HeliusAsset.fromJson(entry as Map<String, Object?>),
  ];
}
