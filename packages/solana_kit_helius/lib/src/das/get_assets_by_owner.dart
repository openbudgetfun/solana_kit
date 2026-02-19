import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `getAssetsByOwner` DAS API method.
///
/// Returns a paginated list of assets owned by the given wallet address.
Future<AssetList> dasGetAssetsByOwner(
  JsonRpcClient rpcClient,
  GetAssetsByOwnerRequest request,
) async {
  final result = await rpcClient.call('getAssetsByOwner', request.toJson());
  return AssetList.fromJson(result! as Map<String, Object?>);
}
