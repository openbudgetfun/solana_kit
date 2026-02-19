import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Calls the Helius create API key endpoint.
///
/// Sends a POST request to `/v0/auth/api-keys?api-key={apiKey}` with the
/// project ID and key name in the request body. Returns the newly created
/// [HeliusApiKey].
Future<HeliusApiKey> authCreateApiKey(
  RestClient restClient,
  String apiKey,
  CreateApiKeyRequest request,
) async {
  final result = await restClient.post(
    '/v0/auth/api-keys?api-key=$apiKey',
    body: request.toJson(),
  );
  return HeliusApiKey.fromJson(result! as Map<String, Object?>);
}
