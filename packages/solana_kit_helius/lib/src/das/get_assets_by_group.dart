import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `getAssetsByGroup` DAS API method.
///
/// Returns a paginated list of assets belonging to the given group
/// (e.g. a collection).
Future<AssetList> dasGetAssetsByGroup(
  JsonRpcClient rpcClient,
  GetAssetsByGroupRequest request,
) async {
  final result = await rpcClient.call('getAssetsByGroup', request.toJson());
  return AssetList.fromJson(result! as Map<String, Object?>);
}
