import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('AuthClient.listProjects', () {
    test(
      'sends GET to /v0/auth/projects and returns list of projects',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/v0/auth/projects');
          expect(request.url.queryParameters['api-key'], isNotEmpty);
          return http.Response(
            jsonEncode(<Object?>[
              <String, Object?>{
                'id': 'p1',
                'name': 'proj1',
                'apiKey': 'k1',
                'createdAt': 1000,
              },
              <String, Object?>{
                'id': 'p2',
                'name': 'proj2',
                'apiKey': 'k2',
                'createdAt': 2000,
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final projects = await helius.auth.listProjects();

        expect(projects, hasLength(2));
        expect(projects[0].id, 'p1');
        expect(projects[0].name, 'proj1');
        expect(projects[1].id, 'p2');
        expect(projects[1].name, 'proj2');
      },
    );

    test('returns empty list when no projects', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<Object?>[]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final projects = await helius.auth.listProjects();

      expect(projects, isEmpty);
    });
  });
}
