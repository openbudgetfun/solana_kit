import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('WebhooksClient.toggleWebhook', () {
    test('sends PATCH and decodes response', () async {
      final mockWebhook = {
        'webhookId': 'wh-1',
        'wallet': 'wallet-addr',
        'webhookUrl': 'https://example.com/hook',
        'transactionTypes': ['TRANSFER'],
        'accountAddresses': ['addr1'],
        'webhookType': 'enhanced',
      };
      final client = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/v0/webhooks/wh-1');
        expect(request.url.queryParameters['api-key'], 'test-key');
        expect(jsonDecode(request.body), {'active': false});
        return http.Response(jsonEncode(mockWebhook), 200);
      });
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final webhook = await helius.webhooks.toggleWebhook(
        'wh-1',
        active: false,
      );

      expect(webhook.webhookId, 'wh-1');
      expect(webhook.webhookType, WebhookType.enhanced);
    });
  });
}
