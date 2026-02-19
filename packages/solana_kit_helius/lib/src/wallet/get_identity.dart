import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/wallet_types.dart';

/// Calls the Helius wallet identity endpoint.
///
/// Sends a GET request to `/v0/addresses/{address}/identity?api-key={apiKey}`.
/// Returns the [Identity] information for the given wallet address.
Future<Identity> walletGetIdentity(
  RestClient restClient,
  String apiKey,
  GetIdentityRequest request,
) async {
  final result = await restClient.get(
    '/v0/addresses/${request.address}/identity?api-key=$apiKey',
  );
  return Identity.fromJson(result! as Map<String, Object?>);
}
