import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/rpc_v2_types.dart';

/// Calls the `getTransactionsForAddress` JSON-RPC method.
///
/// Returns the transaction signatures associated with the address specified
/// in [request], with optional pagination via `before` / `until` cursors.
Future<GetTransactionsForAddressResponse> rpcV2GetTransactionsForAddress(
  JsonRpcClient rpcClient,
  GetTransactionsForAddressRequest request,
) async {
  final result = await rpcClient.call(
    'getTransactionsForAddress',
    request.toJson(),
  );
  return GetTransactionsForAddressResponse.fromJson(
    result! as Map<String, Object?>,
  );
}
