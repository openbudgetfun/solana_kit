import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/webhook_types.dart';
import 'package:solana_kit_helius/src/webhooks/create_webhook.dart';
import 'package:solana_kit_helius/src/webhooks/delete_webhook.dart';
import 'package:solana_kit_helius/src/webhooks/get_all_webhooks.dart';
import 'package:solana_kit_helius/src/webhooks/get_webhook.dart';
import 'package:solana_kit_helius/src/webhooks/update_webhook.dart';

/// Client for Helius Webhooks API methods.
class WebhooksClient {
  const WebhooksClient({required RestClient restClient, required String apiKey})
    : _restClient = restClient,
      _apiKey = apiKey;

  final RestClient _restClient;
  final String _apiKey;

  /// Creates a new webhook with the given configuration.
  Future<Webhook> createWebhook(CreateWebhookRequest request) =>
      webhooksCreateWebhook(_restClient, _apiKey, request);

  /// Returns the webhook configuration for the given [webhookId].
  Future<Webhook> getWebhook(String webhookId) =>
      webhooksGetWebhook(_restClient, _apiKey, webhookId);

  /// Returns all webhooks configured for the current API key.
  Future<List<Webhook>> getAllWebhooks() =>
      webhooksGetAllWebhooks(_restClient, _apiKey);

  /// Updates an existing webhook with the given configuration.
  Future<Webhook> updateWebhook(UpdateWebhookRequest request) =>
      webhooksUpdateWebhook(_restClient, _apiKey, request);

  /// Deletes the webhook with the given [webhookId].
  Future<void> deleteWebhook(String webhookId) =>
      webhooksDeleteWebhook(_restClient, _apiKey, webhookId);
}
