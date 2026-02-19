import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getCompressedTokenAccountsByDelegate', () {
    test('sends correct request and deserializes response', () async {
      final mockResult = <String, Object?>{
        'items': <Object?>[
          <String, Object?>{
            'hash': 'h1',
            'owner': 'o1',
            'mint': 'm1',
            'amount': 100,
            'frozen': false,
          },
        ],
        'cursor': null,
      };

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getCompressedTokenAccountsByDelegate');
        expect(body['jsonrpc'], '2.0');
        expect(body['params'], {'delegate': 'test-delegate'});
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResult}),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.zk.getCompressedTokenAccountsByDelegate(
        GetCompressedTokenAccountsByDelegateRequest(delegate: 'test-delegate'),
      );

      expect(result.items, hasLength(1));
      expect(result.items.first.hash, 'h1');
      expect(result.items.first.owner, 'o1');
      expect(result.items.first.mint, 'm1');
      expect(result.items.first.amount, 100);
      expect(result.items.first.frozen, isFalse);
      expect(result.cursor, isNull);
    });
  });
}
