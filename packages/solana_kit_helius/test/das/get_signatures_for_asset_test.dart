import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('DasClient.getSignaturesForAsset', () {
    test(
      'sends correct JSON-RPC request and deserializes AssetSignatureList',
      () async {
        final mockSignatureList = <String, Object?>{
          'total': 2,
          'limit': 10,
          'items': <Object?>[
            <String, Object?>{
              'signature': 'sig-1',
              'type': 'TRANSFER',
              'slot': 100,
              'timestamp': 1700000000,
            },
            <String, Object?>{
              'signature': 'sig-2',
              'type': 'MINT',
              'slot': 99,
              'timestamp': 1699999000,
            },
          ],
        };

        final client = MockClient((request) async {
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['method'], 'getSignaturesForAsset');
          expect(body['jsonrpc'], '2.0');
          final params = body['params']! as Map<String, Object?>;
          expect(params['id'], 'asset-abc');
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'result': mockSignatureList,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          const HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final result = await helius.das.getSignaturesForAsset(
          const GetSignaturesForAssetRequest(id: 'asset-abc'),
        );

        expect(result.total, 2);
        expect(result.limit, 10);
        expect(result.items.length, 2);
        expect(result.items[0].signature, 'sig-1');
        expect(result.items[0].type_, 'TRANSFER');
        expect(result.items[0].slot, 100);
        expect(result.items[0].timestamp, 1700000000);
        expect(result.items[1].signature, 'sig-2');
        expect(result.items[1].type_, 'MINT');
      },
    );

    test('sends optional pagination parameters', () async {
      final mockSignatureList = <String, Object?>{
        'total': 0,
        'limit': 5,
        'items': <Object?>[],
      };

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final params = body['params']! as Map<String, Object?>;
        expect(params['id'], 'asset-abc');
        expect(params['page'], 2);
        expect(params['limit'], 5);
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': mockSignatureList,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final result = await helius.das.getSignaturesForAsset(
        const GetSignaturesForAssetRequest(id: 'asset-abc', page: 2, limit: 5),
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
              'message': 'Asset not found',
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
        () => helius.das.getSignaturesForAsset(
          const GetSignaturesForAssetRequest(id: 'bad'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
