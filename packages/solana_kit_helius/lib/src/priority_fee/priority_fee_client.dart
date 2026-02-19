import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/priority_fee/get_priority_fee_estimate.dart';
import 'package:solana_kit_helius/src/types/priority_fee_types.dart';

/// Client for Helius priority fee estimation API methods.
class PriorityFeeClient {
  const PriorityFeeClient({required JsonRpcClient rpcClient})
    : _rpcClient = rpcClient;

  final JsonRpcClient _rpcClient;

  /// Returns estimated priority fees for a transaction or set of accounts.
  Future<GetPriorityFeeEstimateResponse> getPriorityFeeEstimate(
    GetPriorityFeeEstimateRequest request,
  ) => priorityFeeGetEstimate(_rpcClient, request);
}
