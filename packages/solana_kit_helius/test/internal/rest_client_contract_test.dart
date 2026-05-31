import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:test/test.dart';

void main() {
  group('RestClient contract', () {
    test('GET merges query parameters with base URLs', () async {
      late http.Request capturedRequest;
      final client = RestClient(
        baseUrl: 'https://api.helius.xyz/v0?api-key=test-key',
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'ok': true}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final response = await client.get(
        '/addresses/demo/balances',
        queryParameters: {'limit': '25', 'cursor': 'next-page'},
      );

      expect(response, {'ok': true});
      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.headers['accept'], 'application/json');
      expect(
        capturedRequest.url.toString(),
        'https://api.helius.xyz/v0/addresses/demo/balances?api-key=test-key&limit=25&cursor=next-page',
      );
    });

    test(
      'POST, PUT, and PATCH send JSON bodies with canonical headers',
      () async {
        final requests = <http.Request>[];
        final client = RestClient(
          baseUrl: 'https://api.helius.xyz',
          client: MockClient((request) async {
            requests.add(request);
            return http.Response(
              jsonEncode({'ok': true}),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );

        await client.post(
          '/v0/webhooks',
          body: {'webhookURL': 'https://example.com'},
        );
        await client.put('/v0/webhooks/123', body: {'status': 'active'});
        await client.patch('/v0/webhooks/123', body: {'isActive': false});

        expect(requests, hasLength(3));
        expect(requests[0].method, 'POST');
        expect(requests[1].method, 'PUT');
        expect(requests[2].method, 'PATCH');
        expect(
          requests.first.headers,
          containsPair('content-type', 'application/json; charset=utf-8'),
        );
        expect(jsonDecode(requests[0].body), {
          'webhookURL': 'https://example.com',
        });
        expect(jsonDecode(requests[1].body), {'status': 'active'});
        expect(jsonDecode(requests[2].body), {'isActive': false});
      },
    );

    test('DELETE returns null for empty success bodies', () async {
      final client = RestClient(
        baseUrl: 'https://api.helius.xyz',
        client: MockClient((request) async {
          expect(request.method, 'DELETE');
          return http.Response('', 204);
        }),
      );

      final response = await client.delete('/v0/webhooks/123');
      expect(response, isNull);
    });

    test('uses the reason phrase for empty non-2xx responses', () async {
      final client = RestClient(
        baseUrl: 'https://api.helius.xyz',
        client: MockClient(
          (_) async =>
              http.Response('', 503, reasonPhrase: 'Service Unavailable'),
        ),
      );

      await expectLater(
        client.get('/v0/addresses/demo/balances'),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.context['message'],
            'message',
            'Service Unavailable',
          ),
        ),
      );
    });

    test('throws SolanaError for non-2xx responses', () async {
      final client = RestClient(
        baseUrl: 'https://api.helius.xyz',
        client: MockClient(
          (_) async => http.Response('denied', 403, reasonPhrase: 'Forbidden'),
        ),
      );

      await expectLater(
        client.get('/v0/addresses/demo/balances'),
        throwsA(
          isA<SolanaError>()
              .having(
                (error) => error.code,
                'code',
                SolanaErrorCode.heliusRestError,
              )
              .having(
                (error) => error.context[SolanaErrorContextKeys.operation],
                'operation',
                'heliusRest',
              )
              .having(
                (error) => error.context[SolanaErrorContextKeys.statusCode],
                'statusCode',
                403,
              )
              .having((error) => error.context['message'], 'message', 'denied'),
        ),
      );
    });
  });
}
