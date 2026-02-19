import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/types/smart_transaction_types.dart';

/// Simulates the transaction to estimate compute units consumed.
///
/// Calls the `simulateTransaction` RPC method with `replaceRecentBlockhash`
/// and `sigVerify` disabled to get a compute unit estimate without requiring
/// valid signatures.
Future<ComputeUnitsEstimate> txGetComputeUnits(
  JsonRpcClient rpcClient,
  CreateSmartTransactionInput input,
) async {
  final result = await rpcClient.call('simulateTransaction', [
    input.toJson(),
    {'replaceRecentBlockhash': true, 'sigVerify': false},
  ]);
  final response = result! as Map<String, Object?>;
  final unitsConsumed = response['value']! as Map<String, Object?>;
  final units = unitsConsumed['unitsConsumed'] as int? ?? 200000;
  return ComputeUnitsEstimate(units: units);
}
