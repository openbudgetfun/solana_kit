import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getMultipleNewAddressProofs', () {
    test('sends correct request and deserializes response', () async {
      final mockResult = <Object?>[
        <String, Object?>{
          'address': 'a1',
          'root': 'r1',
          'proof': <Object?>['p1'],
          'leafIndex': 0,
          'tree': 't1',
        },
        <String, Object?>{
          'address': 'a2',
          'root': 'r2',
          'proof': <Object?>['p2'],
          'leafIndex': 1,
          'tree': 't2',
        },
      ];

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getMultipleNewAddressProofs');
        expect(body['jsonrpc'], '2.0');
        expect(body['params'], {
          'addresses': ['a1', 'a2'],
        });
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResult}),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.zk.getMultipleNewAddressProofs(
        GetMultipleNewAddressProofsRequest(addresses: ['a1', 'a2']),
      );

      expect(result, hasLength(2));
      expect(result[0].address, 'a1');
      expect(result[0].root, 'r1');
      expect(result[0].proof, ['p1']);
      expect(result[0].leafIndex, 0);
      expect(result[0].tree, 't1');
      expect(result[1].address, 'a2');
      expect(result[1].root, 'r2');
      expect(result[1].proof, ['p2']);
      expect(result[1].leafIndex, 1);
      expect(result[1].tree, 't2');
    });
  });
}
