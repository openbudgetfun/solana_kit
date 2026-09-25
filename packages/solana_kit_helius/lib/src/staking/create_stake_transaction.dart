import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/staking_types.dart';

/// Creates a stake transaction via the Helius staking REST API.
///
/// Sends a POST request to `/v0/staking/stake` with the given [request]
/// body and returns the resulting serialized transaction.
Future<StakeTransactionResult> stakingCreateStakeTransaction(
  RestClient restClient,
  String apiKey,
  CreateStakeTransactionRequest request,
) async {
  final result = await restClient.post(
    '/v0/staking/stake?api-key=$apiKey',
    body: request.toJson(),
  );
  return StakeTransactionResult.fromJson(result! as Map<String, Object?>);
}
