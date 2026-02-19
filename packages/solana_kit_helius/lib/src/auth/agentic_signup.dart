import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Calls the Helius agentic signup endpoint.
///
/// Sends a POST request to `/v0/auth/agentic-signup?api-key={apiKey}` with
/// the wallet address in the request body. Returns an
/// [AgenticSignupResponse] containing the new API key and project ID.
Future<AgenticSignupResponse> authAgenticSignup(
  RestClient restClient,
  String apiKey,
  AgenticSignupRequest request,
) async {
  final result = await restClient.post(
    '/v0/auth/agentic-signup?api-key=$apiKey',
    body: request.toJson(),
  );
  return AgenticSignupResponse.fromJson(result! as Map<String, Object?>);
}
