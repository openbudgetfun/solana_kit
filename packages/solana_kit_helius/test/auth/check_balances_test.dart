import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('AuthClient.checkBalances', () {
    test('sends GET to /v0/auth/balances and returns credit info', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v0/auth/balances');
        expect(request.url.queryParameters['api-key'], isNotEmpty);
        return http.Response(
          jsonEncode(<String, Object?>{'credits': 1000, 'creditsUsed': 100}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final balances = await helius.auth.checkBalances();

      expect(balances.credits, 1000);
      expect(balances.creditsUsed, 100);
    });

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(() => helius.auth.checkBalances(), throwsA(isA<Exception>()));
    });
  });
}
