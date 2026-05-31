import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/rpc_v2_types.dart';

/// Calls the `getTransfersByAddress` JSON-RPC method.
Future<GetTransfersByAddressResponse> rpcV2GetTransfersByAddress(
  JsonRpcClient rpcClient,
  GetTransfersByAddressRequest request,
) async {
  final result = await rpcClient.call(
    'getTransfersByAddress',
    request.toJson(),
  );
  return GetTransfersByAddressResponse.fromJson(
    result! as Map<String, Object?>,
  );
}
