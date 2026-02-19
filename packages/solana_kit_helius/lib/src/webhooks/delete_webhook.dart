import 'package:solana_kit_helius/src/internal/rest_client.dart';

/// Calls the Helius delete-webhook endpoint.
///
/// Sends a DELETE request to `/v0/webhooks/{webhookId}?api-key={apiKey}`.
/// Returns nothing on success; throws on failure.
Future<void> webhooksDeleteWebhook(
  RestClient restClient,
  String apiKey,
  String webhookId,
) async {
  await restClient.delete('/v0/webhooks/$webhookId?api-key=$apiKey');
}
