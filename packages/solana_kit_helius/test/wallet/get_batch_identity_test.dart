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
        expect(addresses, contains('alice.sol'));
        expect(addresses, contains('nonexistent-xyz.sol'));
        return http.Response(
          jsonEncode(<Object?>[
            <String, Object?>{
              'address': 'wallet-addr-1',
              'type': 'exchange',
              'name': 'Alice',
              'domain': 'alice.sol',
              'inputDomain': 'alice.sol',
              'socials': <String, Object?>{},
            },
            // A domain that does not resolve still gets an entry, in order.
            <String, Object?>{
              'address': null,
              'type': 'unknown',
              'inputDomain': 'nonexistent-xyz.sol',
              'unresolved': true,
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final identities = await helius.wallet.getBatchIdentity(
        const GetBatchIdentityRequest(
          addresses: ['alice.sol', 'nonexistent-xyz.sol'],
        ),
      );

      expect(identities, hasLength(2));
      final resolved = identities.first as ResolvedBatchIdentity;
      expect(resolved.unresolved, isFalse);
      expect(resolved.address, 'wallet-addr-1');
      expect(resolved.type, 'exchange');
      expect(resolved.name, 'Alice');
      expect(resolved.domain, 'alice.sol');
      expect(resolved.inputDomain, 'alice.sol');
      final unresolved = identities.last as UnresolvedBatchIdentity;
      expect(unresolved.unresolved, isTrue);
      expect(unresolved.address, isNull);
      expect(unresolved.type, 'unknown');
      expect(unresolved.inputDomain, 'nonexistent-xyz.sol');
    });

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
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
