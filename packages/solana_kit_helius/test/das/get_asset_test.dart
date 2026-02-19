import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('DasClient.getAsset', () {
    test('sends correct JSON-RPC request and deserializes response', () async {
      final mockAsset = <String, Object?>{
        'id': 'asset-123',
        'interface': 'V1_NFT',
        'content': <String, Object?>{
          'json_uri': 'https://example.com/metadata.json',
          'metadata': <String, Object?>{'name': 'Test NFT', 'symbol': 'TNFT'},
        },
        'authorities': <Object?>[],
        'compression': <String, Object?>{
          'eligible': false,
          'compressed': false,
        },
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

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getAsset');
        expect(body['jsonrpc'], '2.0');
        final params = body['params']! as Map<String, Object?>;
        expect(params['id'], 'asset-123');
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': mockAsset,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final asset = await helius.das.getAsset(
        const GetAssetRequest(id: 'asset-123'),
      );

      expect(asset.id, 'asset-123');
      expect(asset.interface_, 'V1_NFT');
      expect(asset.content?.metadata?.name, 'Test NFT');
      expect(asset.content?.metadata?.symbol, 'TNFT');
      expect(asset.ownership?.owner, 'owner-address');
      expect(asset.mutable, true);
      expect(asset.burnt, false);
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
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.das.getAsset(const GetAssetRequest(id: 'bad-id')),
        throwsA(isA<Exception>()),
      );
    });
  });
}
