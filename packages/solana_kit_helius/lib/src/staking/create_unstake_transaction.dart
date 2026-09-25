import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/staking_types.dart';

/// Creates an unstake transaction via the Helius staking REST API.
///
/// Sends a POST request to `/v0/staking/unstake` with the given [request]
/// body and returns the resulting serialized transaction.
Future<StakeTransactionResult> stakingCreateUnstakeTransaction(
  RestClient restClient,
  String apiKey,
  CreateUnstakeTransactionRequest request,
) async {
  final result = await restClient.post(
    '/v0/staking/unstake?api-key=$apiKey',
    body: request.toJson(),
  );
  return StakeTransactionResult.fromJson(result! as Map<String, Object?>);
}
