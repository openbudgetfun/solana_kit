import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('sendViaSender', () {
    for (final region in SenderRegion.values) {
      if (region == SenderRegion.defaultRegion) continue;

      test('allows $region only with a controlled-test opt-in', () async {
        final client = MockClient((request) async {
          expect(request.url.scheme, 'http');
          expect(request.url.host, Uri.parse(senderEndpoints[region]!).host);
          expect(request.url.path, '/fast');
          expect(request.url.queryParameters, {'swqos_only': 'true'});
          final body = jsonDecode(request.body) as Map<String, Object?>;
          final params = body['params']! as List<Object?>;
          expect(params.first, 'dGVzdA==');

          return http.Response(jsonEncode('signature'), 200);
        });

        final signature = await sendViaSender(
          'dGVzdA==',
          region: region,
          swqosOnly: true,
          allowInsecureHttpForTesting: true,
          client: client,
        );

        expect(signature, 'signature');
      });

      for (final swqosOnly in [false, true]) {
        test('rejects $region before sending (SWQOS: $swqosOnly)', () async {
          var requests = 0;
          final client = MockClient((request) async {
            requests++;
            return http.Response(jsonEncode('signature'), 200);
          });

          await expectLater(
            sendViaSender(
              'dGVzdA==',
              region: region,
              swqosOnly: swqosOnly,
              client: client,
            ),
            throwsArgumentError,
          );
          expect(requests, 0);
        });
      }
    }

    test('handles a bare-string JSON response', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          senderFastUrl(SenderRegion.defaultRegion),
        );
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'sendTransaction');
        final params = body['params']! as List<Object?>;
        expect(params.first, 'dGVzdA==');
        final options = params[1]! as Map<String, Object?>;
        expect(options, {
          'encoding': 'base64',
          'skipPreflight': true,
          'maxRetries': 0,
        });
        return http.Response(jsonEncode('abc123'), 200);
      });

      final signature = await sendViaSender('dGVzdA==', client: client);

      expect(signature, 'abc123');
    });

    test('handles JSON-RPC object response and SWQOS-only URL', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://sender.helius-rpc.com/fast?swqos_only=true',
        );
        return http.Response(jsonEncode({'result': 'xyz789'}), 200);
      });

      final signature = await sendViaSender(
        'dGVzdA==',
        swqosOnly: true,
        client: client,
      );

      expect(signature, 'xyz789');
    });

    test('throws on JSON-RPC errors and malformed responses', () async {
      final errorClient = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {'message': 'boom'},
          }),
          200,
        ),
      );
      await expectLater(
        sendViaSender('dGVzdA==', client: errorClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('boom'),
          ),
        ),
      );

      final malformedClient = MockClient(
        (_) async => http.Response(jsonEncode({'jsonrpc': '2.0'}), 200),
      );
      await expectLater(
        sendViaSender('dGVzdA==', client: malformedClient),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Unexpected Sender response'),
          ),
        ),
      );
    });

    test('throws nicely on an HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Internal error' * 30, 500);
      });

      expect(
        () => sendViaSender('dGVzdA==', client: client),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Internal error'),
          ),
        ),
      );
    });
  });

  group('sender constants', () {
    for (final region in SenderRegion.values) {
      if (region == SenderRegion.defaultRegion) continue;

      test('rejects $region in URL helpers by default', () {
        expect(() => senderFastUrl(region), throwsArgumentError);
        expect(() => senderPingUrl(region), throwsArgumentError);
        expect(
          senderFastUrl(region, allowInsecureHttpForTesting: true),
          '${senderEndpoints[region]}/fast',
        );
        expect(
          senderPingUrl(region, allowInsecureHttpForTesting: true),
          '${senderEndpoints[region]}/ping',
        );
      });
    }

    test('builds fast and ping URLs', () {
      expect(
        senderFastUrl(SenderRegion.defaultRegion),
        'https://sender.helius-rpc.com/fast',
      );
      expect(
        senderPingUrl(SenderRegion.defaultRegion),
        'https://sender.helius-rpc.com/ping',
      );
      expect(senderTipAccounts, hasLength(10));
      expect(minTipLamportsMax, 1000000);
      expect(minTipLamportsSwqos, 5000);
    });
  });
}
