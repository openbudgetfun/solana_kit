import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getTransactionWithCompressionInfo', () {
    test('sends correct request and deserializes response', () async {
      final mockResult = <String, Object?>{
        'transaction': null,
        'compressionInfo': <String, Object?>{},
      };

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getTransactionWithCompressionInfo');
        expect(body['jsonrpc'], '2.0');
        expect(body['params'], {'signature': 'test-sig'});
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResult}),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.zk.getTransactionWithCompressionInfo(
        GetTransactionWithCompressionInfoRequest(signature: 'test-sig'),
      );

      expect(result.transaction, isNull);
      expect(result.compressionInfo, isA<Map<String, Object?>>());
    });
  });
}
