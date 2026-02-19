import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/webhook_types.dart';

/// Calls the Helius update-webhook endpoint.
///
/// Sends a PUT request to `/v0/webhooks/{webhookId}?api-key={apiKey}` with the
/// updated webhook configuration in the request body. Returns the updated
/// [Webhook].
Future<Webhook> webhooksUpdateWebhook(
  RestClient restClient,
  String apiKey,
  UpdateWebhookRequest request,
) async {
  final result = await restClient.put(
    '/v0/webhooks/${request.webhookId}?api-key=$apiKey',
    body: request.toJson(),
  );
  return Webhook.fromJson(result! as Map<String, Object?>);
}
