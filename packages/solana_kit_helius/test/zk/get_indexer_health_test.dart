import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getIndexerHealth', () {
    test('sends correct request and deserializes response', () async {
      final mockResult = <String, Object?>{'status': 'ok'};

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getIndexerHealth');
        expect(body['jsonrpc'], '2.0');
        expect(body.containsKey('params'), isFalse);
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResult}),
          200,
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test'),
        client: client,
      );
      final result = await helius.zk.getIndexerHealth();

      expect(result.status, 'ok');
    });
  });
}
