import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('WalletClient.getIdentity', () {
    test(
      'sends GET to /v0/addresses/{addr}/identity and deserializes',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/v0/addresses/wallet-addr/identity');
          expect(request.url.queryParameters['api-key'], isNotEmpty);
          return http.Response(
            jsonEncode(<String, Object?>{
              'name': 'Alice',
              'domain': 'alice.sol',
              'socials': <String, Object?>{},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          const HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final identity = await helius.wallet.getIdentity(
          const GetIdentityRequest(address: 'wallet-addr'),
        );

        expect(identity.name, 'Alice');
        expect(identity.domain, 'alice.sol');
        expect(identity.socials, isA<Map<String, Object?>>());
      },
    );

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.wallet.getIdentity(
          const GetIdentityRequest(address: 'unknown-addr'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
