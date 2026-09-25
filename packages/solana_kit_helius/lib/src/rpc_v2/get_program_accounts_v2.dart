import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/rpc_v2_types.dart';

/// Calls the `getProgramAccountsV2` JSON-RPC method.
///
/// Returns a paginated response containing program accounts matching the
/// given [request] filters, along with an optional cursor for fetching the
/// next page.
Future<GetProgramAccountsV2Response> rpcV2GetProgramAccountsV2(
  JsonRpcClient rpcClient,
  GetProgramAccountsV2Request request,
) async {
  final result = await rpcClient.call('getProgramAccountsV2', request.toJson());
  return GetProgramAccountsV2Response.fromJson(result! as Map<String, Object?>);
}
