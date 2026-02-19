import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('WebhooksClient.updateWebhook', () {
    test('sends PUT to correct URL and deserializes response', () async {
      final mockWebhook = {
        'webhookId': 'wh-1',
        'wallet': 'wallet-addr',
        'webhookUrl': 'https://example.com/hook-updated',
        'transactionTypes': ['TRANSFER', 'SWAP'],
        'accountAddresses': ['addr1', 'addr2'],
        'webhookType': 'enhanced',
      };

      final client = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/v0/webhooks/wh-1');
        expect(request.url.queryParameters['api-key'], 'test-key');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['webhookId'], 'wh-1');
        expect(body['webhookUrl'], 'https://example.com/hook-updated');
        expect(body['transactionTypes'], ['TRANSFER', 'SWAP']);
        return http.Response(jsonEncode(mockWebhook), 200);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final webhook = await helius.webhooks.updateWebhook(
        UpdateWebhookRequest(
          webhookId: 'wh-1',
          webhookUrl: 'https://example.com/hook-updated',
          transactionTypes: ['TRANSFER', 'SWAP'],
        ),
      );

      expect(webhook.webhookId, 'wh-1');
      expect(webhook.webhookUrl, 'https://example.com/hook-updated');
      expect(webhook.transactionTypes, ['TRANSFER', 'SWAP']);
      expect(webhook.accountAddresses, ['addr1', 'addr2']);
      expect(webhook.webhookType, WebhookType.enhanced);
    });

    test('sends partial update with only webhookId required', () async {
      final mockWebhook = {
        'webhookId': 'wh-1',
        'wallet': 'wallet-addr',
        'webhookUrl': 'https://example.com/hook',
        'transactionTypes': ['TRANSFER'],
        'accountAddresses': ['addr1'],
        'webhookType': 'enhanced',
      };

      final client = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/v0/webhooks/wh-1');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['webhookId'], 'wh-1');
        // Only webhookId should be present since no other fields were set
        expect(body.containsKey('webhookUrl'), isFalse);
        expect(body.containsKey('transactionTypes'), isFalse);
        expect(body.containsKey('accountAddresses'), isFalse);
        return http.Response(jsonEncode(mockWebhook), 200);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final webhook = await helius.webhooks.updateWebhook(
        UpdateWebhookRequest(webhookId: 'wh-1'),
      );

      expect(webhook.webhookId, 'wh-1');
    });
  });
}
