import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `getSignaturesForAsset` DAS API method.
///
/// Returns a paginated list of transaction signatures associated with the
/// given asset.
Future<AssetSignatureList> dasGetSignaturesForAsset(
  JsonRpcClient rpcClient,
  GetSignaturesForAssetRequest request,
) async {
  final result = await rpcClient.call(
    'getSignaturesForAsset',
    request.toJson(),
  );
  return AssetSignatureList.fromJson(result! as Map<String, Object?>);
}
