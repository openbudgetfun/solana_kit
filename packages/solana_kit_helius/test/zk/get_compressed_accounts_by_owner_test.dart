import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getCompressedAccountsByOwner', () {
    test('sends correct request and deserializes response', () async {
      final mockResult = <String, Object?>{
        'items': <Object?>[
          <String, Object?>{
            'hash': 'h1',
            'address': 'a1',
            'data': <String, Object?>{},
            'owner': 'o1',
            'lamports': 100,
          },
        ],
        'cursor': null,
      };

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getCompressedAccountsByOwner');
        expect(body['jsonrpc'], '2.0');
        expect(body['params'], {'owner': 'test-owner'});
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResult}),
          200,
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test'),
        client: client,
      );
      final result = await helius.zk.getCompressedAccountsByOwner(
        const GetCompressedAccountsByOwnerRequest(owner: 'test-owner'),
      );

      expect(result.items, hasLength(1));
      expect(result.items.first.hash, 'h1');
      expect(result.items.first.address, 'a1');
      expect(result.items.first.owner, 'o1');
      expect(result.items.first.lamports, 100);
      expect(result.cursor, isNull);
    });
  });
}
