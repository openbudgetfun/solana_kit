import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getCompressedAccount', () {
    test(
      'sends correct request and deserializes the wrapped response',
      () async {
        final mockResult = <String, Object?>{
          'context': {'slot': 100},
          'value': {
            'hash': 'h1',
            'address': 'a1',
            'data': <String, Object?>{},
            'owner': 'o1',
            'lamports': 100,
            'seq': 7,
          },
        };

        final client = MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['method'], 'getCompressedAccount');
          expect(body['jsonrpc'], '2.0');
          expect(body['params'], {'hash': 'test-hash'});
          return http.Response(
            jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResult}),
            200,
          );
        });

        final helius = createHelius(
          HeliusConfig(apiKey: 'test'),
          client: client,
        );
        final response = await helius.zk.getCompressedAccount(
          const GetCompressedAccountRequest(hash: 'test-hash'),
        );

        expect(response.slot, 100);
        final account = response.value!;
        expect(account.hash, 'h1');
        expect(account.address, 'a1');
        expect(account.data, <String, Object?>{});
        expect(account.owner, 'o1');
        expect(account.lamports, 100);
        expect(account.seq, 7);
      },
    );

    test('value is null when no account matches', () async {
      // Upstream v4.0.0 #397: absence is null, not an error.
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'context': {'slot': 101},
              'value': null,
            },
          }),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final response = await helius.zk.getCompressedAccount(
        const GetCompressedAccountRequest(hash: 'missing-hash'),
      );

      expect(response.slot, 101);
      expect(response.value, isNull);
    });

    test('address, data, and seq can be null on the wire', () async {
      // Upstream v4.0.0 #397: address and data are null when the account has
      // none, and seq is null for a V2 output-queue account.
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'context': {'slot': 102},
              'value': {
                'hash': 'h2',
                'address': null,
                'data': null,
                'owner': 'o1',
                'lamports': 5,
                'seq': null,
              },
            },
          }),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final response = await helius.zk.getCompressedAccount(
        const GetCompressedAccountRequest(hash: 'h2'),
      );

      final account = response.value!;
      expect(account.address, isNull);
      expect(account.data, isNull);
      expect(account.seq, isNull);
    });
  });
}
