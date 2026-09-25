import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('fetchTipFloor75th', () {
    test('returns the 75-percentile tip when list payload is valid', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getPriorityFeeEstimate');
        return http.Response(
          jsonEncode([
            {'landed_tips_75th_percentile': 0.0013},
          ]),
          200,
        );
      });

      expect(await fetchTipFloor75th(client: client), 0.0013);
    });

    test(
      'returns the 75-percentile tip when result payload is valid',
      () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'result': {'landed_tips_75th_percentile': 0.0021},
            }),
            200,
          );
        });

        expect(await fetchTipFloor75th(client: client), 0.0021);
      },
    );

    test('returns null on malformed payload', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'unexpected': true}), 200);
      });

      expect(await fetchTipFloor75th(client: client), isNull);
    });

    test('returns null on HTTP or network error', () async {
      final httpError = MockClient(
        (request) async => http.Response('Nope', 500),
      );
      final networkError = MockClient(
        (request) async => throw Exception('boom'),
      );

      expect(await fetchTipFloor75th(client: httpError), isNull);
      expect(await fetchTipFloor75th(client: networkError), isNull);
    });
  });
}
