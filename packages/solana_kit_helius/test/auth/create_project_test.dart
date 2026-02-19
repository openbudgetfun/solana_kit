import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('AuthClient.createProject', () {
    test('sends POST to /v0/auth/projects and returns HeliusProject', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v0/auth/projects');
        expect(request.url.queryParameters['api-key'], isNotEmpty);
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['name'], 'proj');
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

      final project = await helius.auth.createProject(
        const CreateProjectRequest(name: 'proj'),
      );

      expect(project.id, 'p1');
      expect(project.name, 'proj');
      expect(project.apiKey, 'k');
      expect(project.createdAt, 1000);
    });

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Conflict', 409);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.auth.createProject(
          const CreateProjectRequest(name: 'dup-proj'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
