import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/rpc_v2_types.dart';

/// Calls the `getTokenAccountsByOwnerV2` JSON-RPC method.
///
/// Returns a paginated response containing token accounts owned by the
/// address specified in [request], along with an optional cursor for
/// fetching the next page.
Future<GetTokenAccountsByOwnerV2Response> rpcV2GetTokenAccountsByOwnerV2(
  JsonRpcClient rpcClient,
  GetTokenAccountsByOwnerV2Request request,
) async {
  final result = await rpcClient.call(
    'getTokenAccountsByOwnerV2',
    request.toJson(),
  );
  return GetTokenAccountsByOwnerV2Response.fromJson(
    result! as Map<String, Object?>,
  );
}
