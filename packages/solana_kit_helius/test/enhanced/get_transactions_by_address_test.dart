import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('EnhancedClient.getTransactionsByAddress', () {
    test('sends GET to correct URL with address', () async {
      final mockTxn = {
        'type': 'TRANSFER',
        'source': 'SYSTEM_PROGRAM',
        'fee': 5000,
        'feePayer': 0,
        'signature': 'sig1',
        'slot': 100,
        'nativeTransfers': <Object?>[],
        'tokenTransfers': <Object?>[],
        'accountData': <Object?>[],
        'instructions': <Object?>[],
        'events': <String, Object?>{},
      };

      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v0/addresses/myAddress/transactions');
        expect(request.url.queryParameters['api-key'], 'test-key');
        return http.Response(jsonEncode([mockTxn]), 200);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final txns = await helius.enhanced.getTransactionsByAddress(
        const GetTransactionsByAddressRequest(address: 'myAddress'),
      );

      expect(txns, hasLength(1));
      expect(txns[0].signature, 'sig1');
      expect(txns[0].type, 'TRANSFER');
      expect(txns[0].source, 'SYSTEM_PROGRAM');
      expect(txns[0].fee, 5000);
      expect(txns[0].slot, 100);
    });

    test('sends optional query parameters', () async {
      final mockTxn = {
        'type': 'SWAP',
        'source': 'JUPITER',
        'fee': 10000,
        'feePayer': 1,
        'signature': 'sig2',
        'slot': 200,
        'nativeTransfers': <Object?>[],
        'tokenTransfers': <Object?>[],
        'accountData': <Object?>[],
        'instructions': <Object?>[],
        'events': <String, Object?>{},
      };

      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.queryParameters['api-key'], 'test-key');
        expect(request.url.queryParameters['before'], 'beforeSig');
        expect(request.url.queryParameters['until'], 'untilSig');
        expect(request.url.queryParameters['commitment'], 'finalized');
        expect(request.url.queryParameters['type'], 'SWAP');
        return http.Response(jsonEncode([mockTxn]), 200);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final txns = await helius.enhanced.getTransactionsByAddress(
        const GetTransactionsByAddressRequest(
          address: 'myAddress',
          before: 'beforeSig',
          until: 'untilSig',
          commitment: CommitmentLevel.finalized,
          type: 'SWAP',
        ),
      );

      expect(txns, hasLength(1));
      expect(txns[0].signature, 'sig2');
      expect(txns[0].type, 'SWAP');
    });
  });
}
