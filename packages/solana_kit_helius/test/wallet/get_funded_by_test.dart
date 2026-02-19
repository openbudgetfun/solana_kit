import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('WalletClient.getFundedBy', () {
    test(
      'sends GET to /v0/addresses/{addr}/funded-by and deserializes',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/v0/addresses/wallet-addr/funded-by');
          expect(request.url.queryParameters['api-key'], isNotEmpty);
          return http.Response(
            jsonEncode(<String, Object?>{
              'transactions': <Object?>[
                <String, Object?>{
                  'signature': 'sig-funded-1',
                  'source': 'funder-addr',
                  'amount': 2000000,
                  'timestamp': 1700000000,
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final result = await helius.wallet.getFundedBy(
          GetFundedByRequest(address: 'wallet-addr'),
        );

        expect(result.transactions, hasLength(1));
        expect(result.transactions[0].signature, 'sig-funded-1');
        expect(result.transactions[0].source, 'funder-addr');
        expect(result.transactions[0].amount, 2000000);
        expect(result.transactions[0].timestamp, 1700000000);
      },
    );

    test('returns empty transactions list', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{'transactions': <Object?>[]}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final result = await helius.wallet.getFundedBy(
        GetFundedByRequest(address: 'unfunded-wallet'),
      );

      expect(result.transactions, isEmpty);
    });
  });
}
