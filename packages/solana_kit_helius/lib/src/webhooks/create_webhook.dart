import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/webhook_types.dart';

/// Calls the Helius create-webhook endpoint.
///
/// Sends a POST request to `/v0/webhooks?api-key={apiKey}` with the webhook
/// configuration in the request body. Returns the newly created [Webhook].
Future<Webhook> webhooksCreateWebhook(
  RestClient restClient,
  String apiKey,
  CreateWebhookRequest request,
) async {
  final result = await restClient.post(
    '/v0/webhooks?api-key=$apiKey',
    body: request.toJson(),
  );
  return Webhook.fromJson(result! as Map<String, Object?>);
}
