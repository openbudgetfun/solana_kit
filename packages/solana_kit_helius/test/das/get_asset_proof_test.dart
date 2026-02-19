import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('DasClient.getAssetProof', () {
    test('sends correct JSON-RPC request and deserializes response', () async {
      final mockProof = <String, Object?>{
        'root': 'r',
        'proof': <Object?>['p1', 'p2'],
        'node_index': 0,
        'leaf': 'l',
        'tree_id': 't',
      };

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getAssetProof');
        expect(body['jsonrpc'], '2.0');
        final params = body['params'] as Map<String, Object?>;
        expect(params['id'], 'x');
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': mockProof,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final proof = await helius.das.getAssetProof(
        GetAssetProofRequest(id: 'x'),
      );

      expect(proof.root, 'r');
      expect(proof.proof, ['p1', 'p2']);
      expect(proof.nodeIndex, 0);
      expect(proof.leaf, 'l');
      expect(proof.treeId, 't');
    });

    test('throws on RPC error', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'error': <String, Object?>{
              'code': -32600,
              'message': 'Asset not found',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.das.getAssetProof(GetAssetProofRequest(id: 'bad')),
        throwsA(isA<Exception>()),
      );
    });
  });
}
