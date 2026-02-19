import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getCompressedBalanceByOwner', () {
    test('sends correct request and deserializes response', () async {
      final mockResult = <String, Object?>{'amount': 3000};

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getCompressedBalanceByOwner');
        expect(body['jsonrpc'], '2.0');
        expect(body['params'], {'owner': 'test-owner'});
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResult}),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.zk.getCompressedBalanceByOwner(
        GetCompressedBalanceByOwnerRequest(owner: 'test-owner'),
      );

      expect(result.amount, 3000);
    });
  });
}
