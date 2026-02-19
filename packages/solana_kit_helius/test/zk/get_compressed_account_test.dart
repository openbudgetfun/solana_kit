import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getCompressedAccount', () {
    test('sends correct request and deserializes response', () async {
      final mockResult = <String, Object?>{
        'hash': 'h1',
        'address': 'a1',
        'data': <String, Object?>{},
        'owner': 'o1',
        'lamports': 100,
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

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.zk.getCompressedAccount(
        GetCompressedAccountRequest(hash: 'test-hash'),
      );

      expect(result.hash, 'h1');
      expect(result.address, 'a1');
      expect(result.data, <String, Object?>{});
      expect(result.owner, 'o1');
      expect(result.lamports, 100);
    });
  });
}
