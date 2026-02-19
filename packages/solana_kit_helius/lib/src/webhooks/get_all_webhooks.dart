import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/webhook_types.dart';

/// Calls the Helius get-all-webhooks endpoint.
///
/// Sends a GET request to `/v0/webhooks?api-key={apiKey}`. Returns a list of
/// all [Webhook] configurations associated with the current API key.
Future<List<Webhook>> webhooksGetAllWebhooks(
  RestClient restClient,
  String apiKey,
) async {
  final result = await restClient.get('/v0/webhooks?api-key=$apiKey');
  final list = result! as List<Object?>;
  return list.cast<Map<String, Object?>>().map(Webhook.fromJson).toList();
}
