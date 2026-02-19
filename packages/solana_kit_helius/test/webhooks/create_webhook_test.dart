import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('WebhooksClient.createWebhook', () {
    test('sends POST and deserializes webhook response', () async {
      final mockWebhook = {
        'webhookId': 'wh-1',
        'wallet': 'wallet-addr',
        'webhookUrl': 'https://example.com/hook',
        'transactionTypes': ['TRANSFER'],
        'accountAddresses': ['addr1'],
        'webhookType': 'enhanced',
      };

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v0/webhooks');
        expect(request.url.queryParameters['api-key'], 'test-key');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['webhookUrl'], 'https://example.com/hook');
        expect(body['transactionTypes'], ['TRANSFER']);
        expect(body['accountAddresses'], ['addr1']);
        expect(body['webhookType'], 'enhanced');
        return http.Response(jsonEncode(mockWebhook), 200);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final webhook = await helius.webhooks.createWebhook(
        const CreateWebhookRequest(
          webhookUrl: 'https://example.com/hook',
          transactionTypes: ['TRANSFER'],
          accountAddresses: ['addr1'],
          webhookType: WebhookType.enhanced,
        ),
      );

      expect(webhook.webhookId, 'wh-1');
      expect(webhook.wallet, 'wallet-addr');
      expect(webhook.webhookUrl, 'https://example.com/hook');
      expect(webhook.transactionTypes, ['TRANSFER']);
      expect(webhook.accountAddresses, ['addr1']);
      expect(webhook.webhookType, WebhookType.enhanced);
      expect(webhook.authHeader, isNull);
    });

    test('sends optional authHeader and txnStatus', () async {
      final mockWebhook = {
        'webhookId': 'wh-2',
        'wallet': 'wallet-addr',
        'webhookUrl': 'https://example.com/hook',
        'transactionTypes': ['TRANSFER'],
        'accountAddresses': ['addr1'],
        'webhookType': 'enhanced',
        'authHeader': 'Bearer secret',
      };

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['authHeader'], 'Bearer secret');
        expect(body['txnStatus'], 'success');
        return http.Response(jsonEncode(mockWebhook), 200);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final webhook = await helius.webhooks.createWebhook(
        const CreateWebhookRequest(
          webhookUrl: 'https://example.com/hook',
          transactionTypes: ['TRANSFER'],
          accountAddresses: ['addr1'],
          webhookType: WebhookType.enhanced,
          authHeader: 'Bearer secret',
          txnStatus: 'success',
        ),
      );

      expect(webhook.webhookId, 'wh-2');
      expect(webhook.authHeader, 'Bearer secret');
    });
  });
}
