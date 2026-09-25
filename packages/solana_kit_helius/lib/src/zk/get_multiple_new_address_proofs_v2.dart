import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

/// Returns validity proofs (V2) for multiple new addresses.
Future<List<NewAddressProof>> zkGetMultipleNewAddressProofsV2(
  JsonRpcClient rpcClient,
  GetMultipleNewAddressProofsRequest request,
) async {
  final result = await rpcClient.call(
    'getMultipleNewAddressProofsV2',
    request.toJson(),
  );
  final list = result! as List<Object?>;
  return list
      .cast<Map<String, Object?>>()
      .map(NewAddressProof.fromJson)
      .toList();
}
