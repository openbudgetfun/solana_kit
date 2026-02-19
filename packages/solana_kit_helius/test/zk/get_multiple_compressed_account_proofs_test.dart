import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getMultipleCompressedAccountProofs', () {
    test('sends correct request and deserializes response', () async {
      final mockResult = <Object?>[
        <String, Object?>{
          'hash': 'h1',
          'root': 'r1',
          'proof': <Object?>['p1'],
          'leafIndex': 0,
        },
        <String, Object?>{
          'hash': 'h2',
          'root': 'r2',
          'proof': <Object?>['p2'],
          'leafIndex': 1,
        },
      ];

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getMultipleCompressedAccountProofs');
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
      final result = await helius.zk.getMultipleCompressedAccountProofs(
        const GetMultipleCompressedAccountProofsRequest(hashes: ['h1', 'h2']),
      );

      expect(result, hasLength(2));
      expect(result[0].hash, 'h1');
      expect(result[0].root, 'r1');
      expect(result[0].proof, ['p1']);
      expect(result[0].leafIndex, 0);
      expect(result[1].hash, 'h2');
      expect(result[1].root, 'r2');
      expect(result[1].proof, ['p2']);
      expect(result[1].leafIndex, 1);
    });
  });
}
