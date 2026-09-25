import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/staking_types.dart';

/// Gets raw stake instructions for building custom transactions.
///
/// Sends a POST request to `/v0/staking/instructions` with the given
/// [request] body and returns the raw instruction data as a map.
Future<Map<String, Object?>> stakingGetStakeInstructions(
  RestClient restClient,
  String apiKey,
  CreateStakeTransactionRequest request,
) async {
  final result = await restClient.post(
    '/v0/staking/instructions?api-key=$apiKey',
    body: request.toJson(),
  );
  return result! as Map<String, Object?>;
}
