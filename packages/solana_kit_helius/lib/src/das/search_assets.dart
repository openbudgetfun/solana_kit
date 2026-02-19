import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `searchAssets` DAS API method.
///
/// Returns a paginated list of assets matching the given filter criteria.
Future<AssetList> dasSearchAssets(
  JsonRpcClient rpcClient,
  SearchAssetsRequest request,
) async {
  final result = await rpcClient.call('searchAssets', request.toJson());
  return AssetList.fromJson(result! as Map<String, Object?>);
}
