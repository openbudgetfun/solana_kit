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
  group('DasClient.getAssetsByCreator', () {
    test('sends correct JSON-RPC request and deserializes AssetList', () async {
      final mockAssetList = <String, Object?>{
        'total': 1,
        'limit': 10,
        'items': <Object?>[_mockAsset('asset-1')],
      };

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getAssetsByCreator');
        expect(body['jsonrpc'], '2.0');
        final params = body['params'] as Map<String, Object?>;
        expect(params['creatorAddress'], 'creator-addr');
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': mockAssetList,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final result = await helius.das.getAssetsByCreator(
        GetAssetsByCreatorRequest(creatorAddress: 'creator-addr'),
      );

      expect(result.total, 1);
      expect(result.limit, 10);
      expect(result.items.length, 1);
      expect(result.items[0].id, 'asset-1');
    });

    test('sends optional onlyVerified parameter', () async {
      final mockAssetList = <String, Object?>{
        'total': 0,
        'limit': 10,
        'items': <Object?>[],
      };

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final params = body['params'] as Map<String, Object?>;
        expect(params['creatorAddress'], 'creator-addr');
        expect(params['onlyVerified'], true);
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': mockAssetList,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final result = await helius.das.getAssetsByCreator(
        GetAssetsByCreatorRequest(
          creatorAddress: 'creator-addr',
          onlyVerified: true,
        ),
      );

      expect(result.total, 0);
      expect(result.items, isEmpty);
    });

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
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.das.getAssetsByCreator(
          GetAssetsByCreatorRequest(creatorAddress: 'bad'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
