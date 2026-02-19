import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('WebhooksClient.getAllWebhooks', () {
    test('sends GET and deserializes list of webhooks', () async {
      final mockWebhooks = [
        {
          'webhookId': 'wh-1',
          'wallet': 'wallet-addr',
          'webhookUrl': 'https://example.com/hook1',
          'transactionTypes': ['TRANSFER'],
          'accountAddresses': ['addr1'],
          'webhookType': 'enhanced',
        },
        {
          'webhookId': 'wh-2',
          'wallet': 'wallet-addr',
          'webhookUrl': 'https://example.com/hook2',
          'transactionTypes': ['SWAP'],
          'accountAddresses': ['addr2'],
          'webhookType': 'raw',
        },
      ];

      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v0/webhooks');
        expect(request.url.queryParameters['api-key'], 'test-key');
        return http.Response(jsonEncode(mockWebhooks), 200);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final webhooks = await helius.webhooks.getAllWebhooks();

      expect(webhooks, hasLength(2));
      expect(webhooks[0].webhookId, 'wh-1');
      expect(webhooks[0].webhookUrl, 'https://example.com/hook1');
      expect(webhooks[0].webhookType, WebhookType.enhanced);
      expect(webhooks[1].webhookId, 'wh-2');
      expect(webhooks[1].webhookUrl, 'https://example.com/hook2');
      expect(webhooks[1].webhookType, WebhookType.raw);
    });

    test('returns empty list when no webhooks', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v0/webhooks');
        expect(request.url.queryParameters['api-key'], 'test-key');
        return http.Response(jsonEncode(<Object?>[]), 200);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final webhooks = await helius.webhooks.getAllWebhooks();

      expect(webhooks, isEmpty);
    });
  });
}
