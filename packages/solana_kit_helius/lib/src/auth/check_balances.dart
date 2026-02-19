import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Calls the Helius check balances endpoint.
///
/// Sends a GET request to `/v0/auth/balances?api-key={apiKey}`. Returns a
/// [CheckBalancesResponse] containing credit balance information.
Future<CheckBalancesResponse> authCheckBalances(
  RestClient restClient,
  String apiKey,
) async {
  final result = await restClient.get('/v0/auth/balances?api-key=$apiKey');
  return CheckBalancesResponse.fromJson(result! as Map<String, Object?>);
}
