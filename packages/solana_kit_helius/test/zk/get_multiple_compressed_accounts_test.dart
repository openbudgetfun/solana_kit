import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getMultipleCompressedAccounts', () {
    test('sends correct request and deserializes response', () async {
      final mockResult = <Object?>[
        <String, Object?>{
          'hash': 'h1',
          'address': 'a1',
          'data': <String, Object?>{},
          'owner': 'o1',
          'lamports': 100,
        },
        <String, Object?>{
          'hash': 'h2',
          'address': 'a2',
          'data': <String, Object?>{},
          'owner': 'o2',
          'lamports': 200,
        },
      ];

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getMultipleCompressedAccounts');
        expect(body['jsonrpc'], '2.0');
        expect(body['params'], {
          'hashes': ['h1', 'h2'],
        });
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResult}),
          200,
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test'),
        client: client,
      );
      final result = await helius.zk.getMultipleCompressedAccounts(
        const GetMultipleCompressedAccountsRequest(hashes: ['h1', 'h2']),
      );

      expect(result, hasLength(2));
      expect(result[0].hash, 'h1');
      expect(result[0].address, 'a1');
      expect(result[0].owner, 'o1');
      expect(result[0].lamports, 100);
      expect(result[1].hash, 'h2');
      expect(result[1].address, 'a2');
      expect(result[1].owner, 'o2');
      expect(result[1].lamports, 200);
    });
  });
}
