import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

Map<String, Object?> _mockAsset(String id) => <String, Object?>{
  'id': id,
  'interface': 'V1_NFT',
  'content': <String, Object?>{
    'json_uri': 'https://example.com/$id.json',
    'metadata': <String, Object?>{'name': 'NFT $id', 'symbol': 'T'},
  },
  'authorities': <Object?>[],
  'compression': <String, Object?>{'eligible': false, 'compressed': false},
  'grouping': <Object?>[],
  'royalty': <String, Object?>{
    'basis_points': 500,
    'primary_sale_happened': true,
  },
  'creators': <Object?>[],
  'ownership': <String, Object?>{
    'owner': 'owner-address',
    'ownership_model': 'single',
  },
  'mutable': true,
  'burnt': false,
};

void main() {
  group('DasClient.getAssetBatch', () {
    test(
      'sends correct JSON-RPC request and deserializes list response',
      () async {
        final mockAssets = <Object?>[_mockAsset('a'), _mockAsset('b')];

        final client = MockClient((request) async {
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['method'], 'getAssetBatch');
          expect(body['jsonrpc'], '2.0');
          final params = body['params']! as Map<String, Object?>;
          expect(params['ids'], ['a', 'b']);
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'result': mockAssets,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          const HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final assets = await helius.das.getAssetBatch(
          const GetAssetBatchRequest(ids: ['a', 'b']),
        );

        expect(assets.length, 2);
        expect(assets[0].id, 'a');
        expect(assets[1].id, 'b');
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
        () => helius.das.getAssetBatch(const GetAssetBatchRequest(ids: ['x'])),
        throwsA(isA<Exception>()),
      );
    });
  });
}
