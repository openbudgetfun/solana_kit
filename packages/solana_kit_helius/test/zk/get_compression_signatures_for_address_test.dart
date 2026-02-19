import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getCompressionSignaturesForAddress', () {
    test('sends correct request and deserializes response', () async {
      final mockResult = <String, Object?>{
        'items': <Object?>[
          <String, Object?>{'signature': 's1', 'slot': 100},
        ],
        'cursor': null,
      };

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getCompressionSignaturesForAddress');
        expect(body['jsonrpc'], '2.0');
        expect(body['params'], {'address': 'test-address'});
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResult}),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.zk.getCompressionSignaturesForAddress(
        GetCompressionSignaturesForAddressRequest(address: 'test-address'),
      );

      expect(result.items, hasLength(1));
      expect(result.items.first.signature, 's1');
      expect(result.items.first.slot, 100);
      expect(result.cursor, isNull);
    });
  });
}
