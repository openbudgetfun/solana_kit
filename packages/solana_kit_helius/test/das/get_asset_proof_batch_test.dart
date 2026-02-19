import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('DasClient.getAssetProofBatch', () {
    test(
      'sends correct JSON-RPC request and deserializes map response',
      () async {
        final mockProofBatch = <String, Object?>{
          'id1': <String, Object?>{
            'root': 'r1',
            'proof': <Object?>['p1'],
            'node_index': 0,
            'leaf': 'l1',
            'tree_id': 't1',
          },
          'id2': <String, Object?>{
            'root': 'r2',
            'proof': <Object?>['p2', 'p3'],
            'node_index': 1,
            'leaf': 'l2',
            'tree_id': 't2',
          },
        };

        final client = MockClient((request) async {
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['method'], 'getAssetProofBatch');
          expect(body['jsonrpc'], '2.0');
          final params = body['params']! as Map<String, Object?>;
          expect(params['ids'], ['id1', 'id2']);
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'result': mockProofBatch,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          const HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final proofs = await helius.das.getAssetProofBatch(
          const GetAssetProofBatchRequest(ids: ['id1', 'id2']),
        );

        expect(proofs.length, 2);
        expect(proofs['id1']?.root, 'r1');
        expect(proofs['id1']?.proof, ['p1']);
        expect(proofs['id1']?.nodeIndex, 0);
        expect(proofs['id1']?.leaf, 'l1');
        expect(proofs['id1']?.treeId, 't1');
        expect(proofs['id2']?.root, 'r2');
        expect(proofs['id2']?.proof, ['p2', 'p3']);
        expect(proofs['id2']?.nodeIndex, 1);
      },
    );

    test('throws on RPC error', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'error': <String, Object?>{
              'code': -32600,
              'message': 'Invalid Request',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.das.getAssetProofBatch(
          const GetAssetProofBatchRequest(ids: ['x']),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
