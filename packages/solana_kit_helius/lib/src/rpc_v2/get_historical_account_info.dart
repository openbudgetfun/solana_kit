import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/rpc_v2_types.dart';

/// Calls the `getHistoricalAccountInfo` JSON-RPC method.
///
/// Returns the account as it was at the position in [request], or a null
/// [GetHistoricalAccountInfoResponse.value] when the account did not exist
/// there (not created yet, or closed). Absence is not an error.
///
/// Beta: mainnet only, Business plans and above, from slot 444959999 onward
/// (earlier slots fail with a Helius RPC error).
Future<GetHistoricalAccountInfoResponse> rpcV2GetHistoricalAccountInfo(
  JsonRpcClient rpcClient,
  GetHistoricalAccountInfoRequest request,
) async {
  final result = await rpcClient.call(
    'getHistoricalAccountInfo',
    request.toJson(),
  );
  return GetHistoricalAccountInfoResponse.fromJson(
    result! as Map<String, Object?>,
  );
}
