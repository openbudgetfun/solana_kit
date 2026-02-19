import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/zk_types.dart';

Future<List<NewAddressProof>> zkGetMultipleNewAddressProofs(
  JsonRpcClient rpcClient,
  GetMultipleNewAddressProofsRequest request,
) async {
  final result = await rpcClient.call(
    'getMultipleNewAddressProofs',
    request.toJson(),
  );
  final list = result! as List<Object?>;
  return list
      .cast<Map<String, Object?>>()
      .map(NewAddressProof.fromJson)
      .toList();
}
