import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('RpcV2Client.getTransactionsForAddress', () {
    test('sends correct request and deserializes response', () async {
      final mockResponse = {
        'transactions': [
          {'signature': 'sig1', 'slot': 100, 'blockTime': 1700000000},
          {'signature': 'sig2', 'slot': 101},
        ],
      };

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['jsonrpc'], '2.0');
        expect(body['method'], 'getTransactionsForAddress');
        final params = body['params']! as Map<String, Object?>;
        expect(params['address'], 'addr1');
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResponse}),
          200,
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test'),
        client: client,
      );
      final result = await helius.rpcV2.getTransactionsForAddress(
        const GetTransactionsForAddressRequest(address: 'addr1'),
      );

      expect(result.transactions, hasLength(2));
      expect(result.transactions[0].signature, 'sig1');
      expect(result.transactions[0].slot, 100);
      expect(result.transactions[0].blockTime, 1700000000);
      expect(result.transactions[1].signature, 'sig2');
      expect(result.transactions[1].slot, 101);
      expect(result.transactions[1].blockTime, isNull);
    });

    test('sends optional parameters', () async {
      final mockResponse = {
        'transactions': [
          {'signature': 'sig1', 'slot': 100},
        ],
      };

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final params = body['params']! as Map<String, Object?>;
        expect(params['address'], 'addr1');
        expect(params['before'], 'beforeSig');
        expect(params['until'], 'untilSig');
        expect(params['limit'], 10);
        expect(params['commitment'], 'confirmed');
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResponse}),
          200,
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test'),
        client: client,
      );
      final result = await helius.rpcV2.getTransactionsForAddress(
        const GetTransactionsForAddressRequest(
          address: 'addr1',
          before: 'beforeSig',
          until: 'untilSig',
          limit: 10,
          commitment: CommitmentLevel.confirmed,
        ),
      );

      expect(result.transactions, hasLength(1));
      expect(result.transactions[0].signature, 'sig1');
    });
  });
}
