import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `getAssetsByCreator` DAS API method.
///
/// Returns a paginated list of assets created by the given creator address.
Future<AssetList> dasGetAssetsByCreator(
  JsonRpcClient rpcClient,
  GetAssetsByCreatorRequest request,
) async {
  final result = await rpcClient.call('getAssetsByCreator', request.toJson());
  return AssetList.fromJson(result! as Map<String, Object?>);
}
