import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/wallet_types.dart';

/// Calls the Helius batch identity endpoint.
///
/// Sends a POST request to `/v0/addresses/identity?api-key={apiKey}` with
/// the list of addresses in the request body. Returns a map of address to
/// [Identity] information.
Future<Map<String, Identity>> walletGetBatchIdentity(
  RestClient restClient,
  String apiKey,
  GetBatchIdentityRequest request,
) async {
  final result = await restClient.post(
    '/v0/addresses/identity?api-key=$apiKey',
    body: {'addresses': request.addresses},
  );
  final map = result! as Map<String, Object?>;
  return map.map(
    (key, value) =>
        MapEntry(key, Identity.fromJson(value! as Map<String, Object?>)),
  );
}
