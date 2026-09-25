import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/webhook_types.dart';

/// Calls the Helius get-webhook endpoint.
///
/// Sends a GET request to `/v0/webhooks/{webhookId}?api-key={apiKey}`.
/// Returns the [Webhook] configuration for the given [webhookId].
Future<Webhook> webhooksGetWebhook(
  RestClient restClient,
  String apiKey,
  String webhookId,
) async {
  final result = await restClient.get(
    '/v0/webhooks/$webhookId?api-key=$apiKey',
  );
  return Webhook.fromJson(result! as Map<String, Object?>);
}
