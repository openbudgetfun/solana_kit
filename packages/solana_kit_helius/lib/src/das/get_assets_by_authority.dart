import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `getAssetsByAuthority` DAS API method.
///
/// Returns a paginated list of assets controlled by the given authority address.
Future<AssetList> dasGetAssetsByAuthority(
  JsonRpcClient rpcClient,
  GetAssetsByAuthorityRequest request,
) async {
  final result = await rpcClient.call('getAssetsByAuthority', request.toJson());
  return AssetList.fromJson(result! as Map<String, Object?>);
}
