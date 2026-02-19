import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('AuthClient.agenticSignup', () {
    test(
      'sends POST to /v0/auth/agentic-signup and deserializes response',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/v0/auth/agentic-signup');
          expect(request.url.queryParameters['api-key'], isNotEmpty);
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['walletAddress'], 'wallet-addr');
          return http.Response(
            jsonEncode(<String, Object?>{'apiKey': 'key', 'projectId': 'proj'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final result = await helius.auth.agenticSignup(
          AgenticSignupRequest(walletAddress: 'wallet-addr'),
        );

        expect(result.apiKey, 'key');
        expect(result.projectId, 'proj');
      },
    );

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.auth.agenticSignup(
          AgenticSignupRequest(walletAddress: 'bad-wallet'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
