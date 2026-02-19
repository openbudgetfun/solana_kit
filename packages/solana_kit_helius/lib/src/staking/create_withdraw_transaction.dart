import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/staking_types.dart';

/// Creates a withdraw transaction via the Helius staking REST API.
///
/// Sends a POST request to `/v0/staking/withdraw` with the given [request]
/// body and returns the resulting serialized transaction.
Future<StakeTransactionResult> stakingCreateWithdrawTransaction(
  RestClient restClient,
  String apiKey,
  CreateWithdrawTransactionRequest request,
) async {
  final result = await restClient.post(
    '/v0/staking/withdraw?api-key=$apiKey',
    body: request.toJson(),
  );
  return StakeTransactionResult.fromJson(result! as Map<String, Object?>);
}
