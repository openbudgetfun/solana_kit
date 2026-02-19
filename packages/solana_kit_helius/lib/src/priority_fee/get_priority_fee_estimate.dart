import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/priority_fee_types.dart';

/// Calls the `getPriorityFeeEstimate` JSON-RPC method.
///
/// Returns estimated priority fees based on the given [request] parameters,
/// which may include account keys, a serialized transaction, and estimation
/// options such as the desired priority level.
Future<GetPriorityFeeEstimateResponse> priorityFeeGetEstimate(
  JsonRpcClient rpcClient,
  GetPriorityFeeEstimateRequest request,
) async {
  final result = await rpcClient.call(
    'getPriorityFeeEstimate',
    request.toJson(),
  );
  return GetPriorityFeeEstimateResponse.fromJson(
    result! as Map<String, Object?>,
  );
}
