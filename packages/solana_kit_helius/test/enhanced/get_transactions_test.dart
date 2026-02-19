import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('EnhancedClient.getTransactions', () {
    test('sends POST with transaction signatures', () async {
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
        expect(request.method, 'POST');
        expect(request.url.path, '/v0/transactions');
        expect(request.url.queryParameters['api-key'], 'test-key');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['transactions'], ['sig1', 'sig2']);
        return http.Response(jsonEncode([mockTxn]), 200);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final txns = await helius.enhanced.getTransactions(
        const GetTransactionsRequest(transactions: ['sig1', 'sig2']),
      );

      expect(txns, hasLength(1));
      expect(txns[0].signature, 'sig1');
      expect(txns[0].type, 'TRANSFER');
      expect(txns[0].source, 'SYSTEM_PROGRAM');
      expect(txns[0].fee, 5000);
      expect(txns[0].feePayer, 0);
      expect(txns[0].slot, 100);
      expect(txns[0].nativeTransfers, isEmpty);
      expect(txns[0].tokenTransfers, isEmpty);
      expect(txns[0].accountData, isEmpty);
      expect(txns[0].instructions, isEmpty);
    });

    test('deserializes multiple transactions', () async {
      final mockTxns = [
        {
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
        },
        {
          'type': 'SWAP',
          'source': 'JUPITER',
          'fee': 10000,
          'feePayer': 1,
          'signature': 'sig2',
          'slot': 101,
          'timestamp': 1700000000,
          'description': 'A swap transaction',
          'nativeTransfers': <Object?>[],
          'tokenTransfers': <Object?>[],
          'accountData': <Object?>[],
          'instructions': <Object?>[],
          'events': <String, Object?>{},
        },
      ];

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockTxns), 200);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final txns = await helius.enhanced.getTransactions(
        const GetTransactionsRequest(transactions: ['sig1', 'sig2']),
      );

      expect(txns, hasLength(2));
      expect(txns[0].signature, 'sig1');
      expect(txns[0].type, 'TRANSFER');
      expect(txns[1].signature, 'sig2');
      expect(txns[1].type, 'SWAP');
      expect(txns[1].timestamp, 1700000000);
      expect(txns[1].description, 'A swap transaction');
    });
  });
}
