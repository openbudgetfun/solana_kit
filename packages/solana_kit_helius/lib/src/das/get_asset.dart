import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `getAsset` DAS API method.
///
/// Returns the metadata for a single digital asset identified by its id.
Future<HeliusAsset> dasGetAsset(
  JsonRpcClient rpcClient,
  GetAssetRequest request,
) async {
  final result = await rpcClient.call('getAsset', request.toJson());
  return HeliusAsset.fromJson(result! as Map<String, Object?>);
}
