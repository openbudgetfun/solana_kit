import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('WalletClient.getHistory', () {
    test(
      'sends GET to /v0/addresses/{addr}/transactions and returns enhanced txns',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/v0/addresses/wallet-addr/transactions');
          expect(request.url.queryParameters['api-key'], isNotEmpty);
          return http.Response(
            jsonEncode(<Object?>[
              <String, Object?>{
                'type': 'TRANSFER',
                'source': 'SYSTEM_PROGRAM',
                'fee': 5000,
                'feePayer': 0,
                'signature': 'sig-hist-1',
                'slot': 100,
                'nativeTransfers': <Object?>[],
                'tokenTransfers': <Object?>[],
                'accountData': <Object?>[],
                'instructions': <Object?>[],
                'events': <String, Object?>{},
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          const HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final history = await helius.wallet.getHistory(
          const GetHistoryRequest(address: 'wallet-addr'),
        );

        expect(history, hasLength(1));
        expect(history[0].signature, 'sig-hist-1');
        expect(history[0].type, 'TRANSFER');
        expect(history[0].source, 'SYSTEM_PROGRAM');
        expect(history[0].fee, 5000);
        expect(history[0].slot, 100);
      },
    );

    test('returns empty list when no transactions', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<Object?>[]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final history = await helius.wallet.getHistory(
        const GetHistoryRequest(address: 'new-wallet'),
      );

      expect(history, isEmpty);
    });
  });
}
