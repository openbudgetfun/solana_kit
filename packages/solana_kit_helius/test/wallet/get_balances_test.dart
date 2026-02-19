import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('WalletClient.getBalances', () {
    test(
      'sends GET to /v0/addresses/{addr}/balances and deserializes',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/v0/addresses/wallet-addr/balances');
          expect(request.url.queryParameters['api-key'], isNotEmpty);
          return http.Response(
            jsonEncode(<String, Object?>{
              'nativeBalance': 1000000,
              'tokens': <Object?>[
                <String, Object?>{'mint': 'm1', 'amount': 500, 'decimals': 9},
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          const HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final balances = await helius.wallet.getBalances(
          const GetBalancesRequest(address: 'wallet-addr'),
        );

        expect(balances.nativeBalance, 1000000);
        expect(balances.tokens, hasLength(1));
        expect(balances.tokens[0].mint, 'm1');
        expect(balances.tokens[0].amount, 500);
        expect(balances.tokens[0].decimals, 9);
      },
    );

    test('handles empty token list', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'nativeBalance': 0,
            'tokens': <Object?>[],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final balances = await helius.wallet.getBalances(
        const GetBalancesRequest(address: 'empty-wallet'),
      );

      expect(balances.nativeBalance, 0);
      expect(balances.tokens, isEmpty);
    });
  });
}
