import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('WalletClient.getBatchIdentity', () {
    test('sends POST to /v0/addresses/identity with addresses list', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v0/addresses/identity');
        expect(request.url.queryParameters['api-key'], isNotEmpty);
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final addresses = (body['addresses']! as List<Object?>).cast<String>();
        expect(addresses, contains('addr1'));
        expect(addresses, contains('addr2'));
        return http.Response(
          jsonEncode(<String, Object?>{
            'addr1': <String, Object?>{
              'name': 'Alice',
              'domain': 'alice.sol',
              'socials': <String, Object?>{},
            },
            'addr2': <String, Object?>{
              'name': 'Bob',
              'domain': 'bob.sol',
              'socials': <String, Object?>{},
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final identities = await helius.wallet.getBatchIdentity(
        const GetBatchIdentityRequest(addresses: ['addr1', 'addr2']),
      );

      expect(identities, hasLength(2));
      expect(identities['addr1']?.name, 'Alice');
      expect(identities['addr1']?.domain, 'alice.sol');
      expect(identities['addr2']?.name, 'Bob');
      expect(identities['addr2']?.domain, 'bob.sol');
    });

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.wallet.getBatchIdentity(
          const GetBatchIdentityRequest(addresses: ['addr1']),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
