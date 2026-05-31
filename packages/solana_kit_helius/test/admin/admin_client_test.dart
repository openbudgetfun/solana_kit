import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('AdminClient.getProjectUsage', () {
    test('sends authenticated GET and decodes usage', () async {
      final client = AdminClient(
        baseUrl: 'https://api.helius.xyz/v0',
        apiKey: 'admin-key',
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString(),
            'https://api.helius.xyz/v0/admin/projects/project-1/usage',
          );
          expect(request.headers['accept'], 'application/json');
          expect(request.headers['content-type'], 'application/json');
          expect(request.headers['x-api-key'], 'admin-key');
          return http.Response(jsonEncode(projectUsageJson()), 200);
        }),
      );

      final usage = await client.getProjectUsage('project-1');

      expect(usage.creditsRemaining, 900);
      expect(usage.subscriptionDetails.plan, 'business');
      expect(usage.usage.websocket, 10);
    });

    test('throws SolanaError for non-2xx response body', () async {
      final client = AdminClient(
        baseUrl: 'https://api.helius.xyz',
        apiKey: 'admin-key',
        client: MockClient((_) async => http.Response('forbidden', 403)),
      );

      await expectLater(
        client.getProjectUsage('project-1'),
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
                'heliusAdmin',
              )
              .having(
                (error) => error.context[SolanaErrorContextKeys.statusCode],
                'statusCode',
                403,
              )
              .having(
                (error) => error.context['message'],
                'message',
                'forbidden',
              ),
        ),
      );
    });

    test('uses reason phrase when error body is empty', () async {
      final client = AdminClient(
        baseUrl: 'https://api.helius.xyz',
        apiKey: 'admin-key',
        client: MockClient(
          (_) async => http.Response('', 500, reasonPhrase: 'Server error'),
        ),
      );

      await expectLater(
        client.getProjectUsage('project-1'),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.context['message'],
            'message',
            'Server error',
          ),
        ),
      );
    });
  });
}

Map<String, Object?> projectUsageJson() => {
  'creditsRemaining': 900,
  'creditsUsed': 100,
  'prepaidCreditsRemaining': 50,
  'prepaidCreditsUsed': 10,
  'subscriptionDetails': {
    'billingCycle': {'start': '2026-05-01', 'end': '2026-06-01'},
    'creditsLimit': 1000,
    'plan': 'business',
  },
  'usage': {
    'api': 1,
    'archival': 2,
    'das': 3,
    'grpc': 4,
    'grpcGeyser': 5,
    'photon': 6,
    'rpc': 7,
    'stream': 8,
    'webhook': 9,
    'websocket': 10,
  },
};
