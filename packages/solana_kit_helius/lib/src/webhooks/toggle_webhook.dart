import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/webhook_types.dart';

/// Toggles a webhook's active state.
Future<Webhook> webhooksToggleWebhook(
  RestClient restClient,
  String apiKey,
  String webhookId, {
  required bool active,
}) async {
  final result = await restClient.patch(
    '/v0/webhooks/$webhookId?api-key=$apiKey',
    body: {'active': active},
  );
  return Webhook.fromJson(result! as Map<String, Object?>);
}
