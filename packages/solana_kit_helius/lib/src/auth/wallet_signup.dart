import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Calls the Helius wallet signup endpoint.
///
/// Sends a POST request to `/v0/auth/wallet-signup?api-key={apiKey}` with
/// the wallet address, signature, and message in the request body. Returns a
/// [WalletSignupResponse] containing the new API key and project ID.
Future<WalletSignupResponse> authWalletSignup(
  RestClient restClient,
  String apiKey,
  WalletSignupRequest request,
) async {
  final result = await restClient.post(
    '/v0/auth/wallet-signup?api-key=$apiKey',
    body: request.toJson(),
  );
  return WalletSignupResponse.fromJson(result! as Map<String, Object?>);
}
