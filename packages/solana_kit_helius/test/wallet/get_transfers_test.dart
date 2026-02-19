import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('WalletClient.getTransfers', () {
    test(
      'sends GET to /v0/addresses/{addr}/transfers and returns list',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/v0/addresses/wallet-addr/transfers');
          expect(request.url.queryParameters['api-key'], isNotEmpty);
          return http.Response(
            jsonEncode(<Object?>[
              <String, Object?>{
                'signature': 'sig-transfer-1',
                'from': 'sender-addr',
                'to': 'receiver-addr',
                'amount': 1000000,
                'timestamp': 1700000000,
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

        final transfers = await helius.wallet.getTransfers(
          const GetTransfersRequest(address: 'wallet-addr'),
        );

        expect(transfers, hasLength(1));
        expect(transfers[0].signature, 'sig-transfer-1');
        expect(transfers[0].from, 'sender-addr');
        expect(transfers[0].to, 'receiver-addr');
        expect(transfers[0].amount, 1000000);
        expect(transfers[0].timestamp, 1700000000);
      },
    );

    test('returns empty list when no transfers', () async {
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

      final transfers = await helius.wallet.getTransfers(
        const GetTransfersRequest(address: 'empty-wallet'),
      );

      expect(transfers, isEmpty);
    });
  });
}
