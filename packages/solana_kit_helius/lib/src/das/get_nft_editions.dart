import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/das_types.dart';

/// Calls the `getNftEditions` DAS API method.
///
/// Returns a list of edition records for the given NFT mint.
Future<List<NftEdition>> dasGetNftEditions(
  JsonRpcClient rpcClient,
  GetNftEditionsRequest request,
) async {
  final result = await rpcClient.call('getNftEditions', request.toJson());
  final list = result! as List<Object?>;
  return list.cast<Map<String, Object?>>().map(NftEdition.fromJson).toList();
}
