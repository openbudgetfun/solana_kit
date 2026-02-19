import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getCompressedTokenBalancesByOwnerV2', () {
    test('sends correct request and deserializes response', () async {
      final mockResult = <String, Object?>{
        'items': <Object?>[
          <String, Object?>{'mint': 'm1', 'amount': 500, 'decimals': 9},
        ],
        'cursor': null,
      };

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getCompressedTokenBalancesByOwnerV2');
        expect(body['jsonrpc'], '2.0');
        expect(body['params'], {'owner': 'test-owner'});
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResult}),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.zk.getCompressedTokenBalancesByOwnerV2(
        GetCompressedTokenBalancesByOwnerRequest(owner: 'test-owner'),
      );

      expect(result.items, hasLength(1));
      expect(result.items.first.mint, 'm1');
      expect(result.items.first.amount, 500);
      expect(result.items.first.decimals, 9);
      expect(result.cursor, isNull);
    });
  });
}
