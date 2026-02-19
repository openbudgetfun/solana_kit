import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('WebhooksClient.deleteWebhook', () {
    test('sends DELETE to correct URL', () async {
      final client = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/v0/webhooks/wh-1');
        expect(request.url.queryParameters['api-key'], 'test-key');
        return http.Response('', 200);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      // Should complete without throwing.
      await helius.webhooks.deleteWebhook('wh-1');
    });

    test('sends DELETE with different webhook id', () async {
      final client = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/v0/webhooks/wh-abc-123');
        expect(request.url.queryParameters['api-key'], 'my-api-key');
        return http.Response('', 200);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'my-api-key'),
        client: client,
      );

      await helius.webhooks.deleteWebhook('wh-abc-123');
    });
  });
}
