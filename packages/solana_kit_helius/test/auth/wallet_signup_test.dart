import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('AuthClient.walletSignup', () {
    test(
      'sends POST to /v0/auth/wallet-signup with signature verification',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/v0/auth/wallet-signup');
          expect(request.url.queryParameters['api-key'], isNotEmpty);
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['walletAddress'], 'wallet-addr');
          expect(body['signature'], 'sig-data');
          expect(body['message'], 'auth-message');
          return http.Response(
            jsonEncode(<String, Object?>{
              'apiKey': 'key-ws',
              'projectId': 'proj-ws',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          const HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final result = await helius.auth.walletSignup(
          const WalletSignupRequest(
            walletAddress: 'wallet-addr',
            signature: 'sig-data',
            message: 'auth-message',
          ),
        );

        expect(result.apiKey, 'key-ws');
        expect(result.projectId, 'proj-ws');
      },
    );

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Forbidden', 403);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.auth.walletSignup(
          const WalletSignupRequest(
            walletAddress: 'w',
            signature: 's',
            message: 'm',
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
