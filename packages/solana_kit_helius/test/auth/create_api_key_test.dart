import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('AuthClient.createApiKey', () {
    test('sends POST to /v0/auth/api-keys and returns HeliusApiKey', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v0/auth/api-keys');
        expect(request.url.queryParameters['api-key'], isNotEmpty);
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['projectId'], 'p1');
        expect(body['name'], 'test');
        return http.Response(
          jsonEncode(<String, Object?>{
            'id': 'k1',
            'key': 'secret',
            'name': 'test',
            'createdAt': 1000,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final apiKey = await helius.auth.createApiKey(
        CreateApiKeyRequest(projectId: 'p1', name: 'test'),
      );

      expect(apiKey.id, 'k1');
      expect(apiKey.key, 'secret');
      expect(apiKey.name, 'test');
      expect(apiKey.createdAt, 1000);
    });

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.auth.createApiKey(
          CreateApiKeyRequest(projectId: 'p1', name: 'bad'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
