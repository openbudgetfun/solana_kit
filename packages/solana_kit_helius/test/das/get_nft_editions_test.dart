import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('DasClient.getNftEditions', () {
    test(
      'sends correct JSON-RPC request and deserializes list response',
      () async {
        final mockEditions = <Object?>[
          <String, Object?>{'mint': 'mint-1', 'edition': 1},
          <String, Object?>{'mint': 'mint-2', 'edition': 2},
        ];

        final client = MockClient((request) async {
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['method'], 'getNftEditions');
          expect(body['jsonrpc'], '2.0');
          final params = body['params']! as Map<String, Object?>;
          expect(params['mint'], 'master-mint');
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'result': mockEditions,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          const HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final editions = await helius.das.getNftEditions(
          const GetNftEditionsRequest(mint: 'master-mint'),
        );

        expect(editions.length, 2);
        expect(editions[0].mint, 'mint-1');
        expect(editions[0].edition, 1);
        expect(editions[1].mint, 'mint-2');
        expect(editions[1].edition, 2);
      },
    );

    test('sends optional pagination parameters', () async {
      final mockEditions = <Object?>[
        <String, Object?>{'mint': 'mint-3', 'edition': 3},
      ];

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final params = body['params']! as Map<String, Object?>;
        expect(params['mint'], 'master-mint');
        expect(params['page'], 2);
        expect(params['limit'], 5);
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': mockEditions,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final editions = await helius.das.getNftEditions(
        const GetNftEditionsRequest(mint: 'master-mint', page: 2, limit: 5),
      );

      expect(editions.length, 1);
      expect(editions[0].mint, 'mint-3');
      expect(editions[0].edition, 3);
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
        () =>
            helius.das.getNftEditions(const GetNftEditionsRequest(mint: 'bad')),
        throwsA(isA<Exception>()),
      );
    });
  });
}
