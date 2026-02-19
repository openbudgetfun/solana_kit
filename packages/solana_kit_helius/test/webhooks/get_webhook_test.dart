import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('WebhooksClient.getWebhook', () {
    test('sends GET to correct URL and deserializes response', () async {
      final mockWebhook = {
        'webhookId': 'wh-1',
        'wallet': 'wallet-addr',
        'webhookUrl': 'https://example.com/hook',
        'transactionTypes': ['TRANSFER'],
        'accountAddresses': ['addr1'],
        'webhookType': 'enhanced',
      };

      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v0/webhooks/wh-1');
        expect(request.url.queryParameters['api-key'], 'test-key');
        return http.Response(jsonEncode(mockWebhook), 200);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final webhook = await helius.webhooks.getWebhook('wh-1');

      expect(webhook.webhookId, 'wh-1');
      expect(webhook.wallet, 'wallet-addr');
      expect(webhook.webhookUrl, 'https://example.com/hook');
      expect(webhook.transactionTypes, ['TRANSFER']);
      expect(webhook.accountAddresses, ['addr1']);
      expect(webhook.webhookType, WebhookType.enhanced);
    });

    test('deserializes webhook with authHeader', () async {
      final mockWebhook = {
        'webhookId': 'wh-2',
        'wallet': 'wallet-addr',
        'webhookUrl': 'https://example.com/hook',
        'transactionTypes': ['TRANSFER', 'SWAP'],
        'accountAddresses': ['addr1', 'addr2'],
        'webhookType': 'raw',
        'authHeader': 'Bearer token123',
      };

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockWebhook), 200);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final webhook = await helius.webhooks.getWebhook('wh-2');

      expect(webhook.webhookId, 'wh-2');
      expect(webhook.webhookType, WebhookType.raw);
      expect(webhook.authHeader, 'Bearer token123');
      expect(webhook.transactionTypes, hasLength(2));
      expect(webhook.accountAddresses, hasLength(2));
    });
  });
}
