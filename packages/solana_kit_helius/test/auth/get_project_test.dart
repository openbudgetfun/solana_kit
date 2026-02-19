import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('AuthClient.getProject', () {
    test(
      'sends GET to /v0/auth/projects/{id} and returns HeliusProject',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/v0/auth/projects/p1');
          expect(request.url.queryParameters['api-key'], isNotEmpty);
          return http.Response(
            jsonEncode(<String, Object?>{
              'id': 'p1',
              'name': 'proj',
              'apiKey': 'k',
              'createdAt': 1000,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          const HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final project = await helius.auth.getProject('p1');

        expect(project.id, 'p1');
        expect(project.name, 'proj');
        expect(project.apiKey, 'k');
        expect(project.createdAt, 1000);
      },
    );

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.auth.getProject('nonexistent'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
