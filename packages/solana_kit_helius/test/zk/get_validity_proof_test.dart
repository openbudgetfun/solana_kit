import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ZkClient.getValidityProof', () {
    test('deserializes the proof components as byte arrays', () async {
      // Upstream v4.0.0 #397: a, b, and c are the curve points' bytes as
      // integer arrays, not base64 strings.
      final mockResult = <String, Object?>{
        'context': {'slot': 55},
        'value': {
          'compressedProof': {
            'a': [1, 2, 3],
            'b': [4, 5],
            'c': [6, 7, 8],
          },
          'leafIndices': [0],
          'leaves': ['leaf-1'],
          'merkleTrees': ['tree-1'],
          'rootIndices': [9],
          'roots': ['root-1'],
        },
      };

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getValidityProof');
        expect(body['jsonrpc'], '2.0');
        expect(body['params'], {
          'hashes': ['h1'],
        });
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResult}),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final response = await helius.zk.getValidityProof(
        const GetValidityProofRequest(hashes: ['h1']),
      );

      expect(response.slot, 55);
      expect(response.value.compressedProof.a, [1, 2, 3]);
      expect(response.value.compressedProof.b, [4, 5]);
      expect(response.value.compressedProof.c, [6, 7, 8]);
      expect(response.value.leafIndices, [0]);
      expect(response.value.leaves, ['leaf-1']);
      expect(response.value.merkleTrees, ['tree-1']);
      expect(response.value.rootIndices, [9]);
      expect(response.value.roots, ['root-1']);
    });
  });
}
