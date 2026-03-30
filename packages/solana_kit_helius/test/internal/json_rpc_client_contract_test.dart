import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:test/test.dart';

void main() {
  group('JsonRpcClient contract', () {
    test('sends canonical JSON-RPC envelopes and increments ids', () async {
      final requests = <http.Request>[];
      final client = JsonRpcClient(
        url: 'https://mainnet.helius-rpc.com/?api-key=test-key',
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode({'jsonrpc': '2.0', 'id': requests.length, 'result': 'ok'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      await client.call('getAssetsByOwner', {'ownerAddress': 'owner-1'});
      await client.call('getAsset', {'id': 'asset-1'});

      expect(requests, hasLength(2));
      expect(requests.first.method, 'POST');
      expect(requests.first.headers['accept'], 'application/json');
      expect(
        requests.first.headers['content-type'],
        'application/json; charset=utf-8',
      );

      final firstEnvelope =
          jsonDecode(requests.first.body) as Map<String, Object?>;
      expect(firstEnvelope['jsonrpc'], '2.0');
      expect(firstEnvelope['id'], 1);
      expect(firstEnvelope['method'], 'getAssetsByOwner');
      expect(firstEnvelope['params'], {'ownerAddress': 'owner-1'});

      final secondEnvelope =
          jsonDecode(requests.last.body) as Map<String, Object?>;
      expect(secondEnvelope['id'], 2);
      expect(secondEnvelope['method'], 'getAsset');
      expect(secondEnvelope['params'], {'id': 'asset-1'});
    });

    test('throws SolanaError for non-200 responses', () async {
      final client = JsonRpcClient(
        url: 'https://mainnet.helius-rpc.com/?api-key=test-key',
        client: MockClient(
          (_) async => http.Response('rate limited', 429, reasonPhrase: 'Too Many Requests'),
        ),
      );

      await expectLater(
        client.call('getAsset', {'id': 'asset-1'}),
        throwsA(
          isA<SolanaError>()
              .having(
                (error) => error.code,
                'code',
                SolanaErrorCode.heliusRpcError,
              )
              .having(
                (error) => error.context[SolanaErrorContextKeys.methodName],
                'methodName',
                'getAsset',
              )
              .having(
                (error) => error.context[SolanaErrorContextKeys.statusCode],
                'statusCode',
                429,
              )
              .having(
                (error) => error.context['message'],
                'message',
                contains('HTTP 429'),
              ),
        ),
      );
    });

    test('throws SolanaError for JSON-RPC error payloads', () async {
      final client = JsonRpcClient(
        url: 'https://mainnet.helius-rpc.com/?api-key=test-key',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'error': {'code': -32000, 'message': 'subscription denied'},
            }),
            200,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );

      await expectLater(
        client.call('getAsset', {'id': 'asset-1'}),
        throwsA(
          isA<SolanaError>()
              .having(
                (error) => error.code,
                'code',
                SolanaErrorCode.heliusRpcError,
              )
              .having(
                (error) => error.context[SolanaErrorContextKeys.methodName],
                'methodName',
                'getAsset',
              )
              .having(
                (error) => error.context[SolanaErrorContextKeys.url],
                'url',
                'https://mainnet.helius-rpc.com/?api-key=test-key',
              )
              .having(
                (error) => error.context['message'],
                'message',
                'subscription denied',
              ),
        ),
      );
    });
  });
}
