import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_surfpool/src/errors.dart';
import 'package:solana_kit_surfpool/src/internal/json_rpc_client.dart';
import 'package:test/test.dart';

void main() {
  group('SurfpoolJsonRpcClient', () {
    test('sends JSON-RPC envelopes and increments ids', () async {
      final requests = <http.Request>[];
      final client = SurfpoolJsonRpcClient(
        url: Uri.parse('http://127.0.0.1:8899'),
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': requests.length,
              'result': 'ok',
            }),
            200,
          );
        }),
      );

      await client.call('getHealth');
      await client.call('surfnet_setAccount', <Object?>[
        '11111111111111111111111111111111',
        <String, Object?>{'lamports': 1},
      ]);

      expect(requests, hasLength(2));
      expect(requests.first.method, 'POST');
      expect(requests.first.headers['accept'], 'application/json');
      expect(
        requests.first.headers['content-type'],
        'application/json; charset=utf-8',
      );

      final first = jsonDecode(requests.first.body) as Map<String, Object?>;
      expect(first, <String, Object?>{
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'getHealth',
      });

      final second = jsonDecode(requests.last.body) as Map<String, Object?>;
      expect(second['id'], 2);
      expect(second['method'], 'surfnet_setAccount');
      expect(second['params'], <Object?>[
        '11111111111111111111111111111111',
        <String, Object?>{'lamports': 1},
      ]);
    });

    test('throws for non-200 responses', () async {
      final client = SurfpoolJsonRpcClient(
        url: Uri.parse('http://127.0.0.1:8899'),
        client: MockClient(
          (_) async =>
              http.Response('nope', 500, reasonPhrase: 'Internal Server Error'),
        ),
      );

      await expectLater(
        client.call('getHealth'),
        throwsA(
          isA<SurfpoolRpcException>()
              .having((error) => error.method, 'method', 'getHealth')
              .having((error) => error.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('throws for JSON-RPC error payloads', () async {
      final client = SurfpoolJsonRpcClient(
        url: Uri.parse('http://127.0.0.1:8899'),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'error': <String, Object?>{
                'code': -32000,
                'message': 'cheatcode failed',
              },
            }),
            200,
          ),
        ),
      );

      await expectLater(
        client.call('surfnet_setAccount'),
        throwsA(
          isA<SurfpoolRpcException>()
              .having((error) => error.method, 'method', 'surfnet_setAccount')
              .having((error) => error.rpcCode, 'rpcCode', -32000)
              .having((error) => error.message, 'message', 'cheatcode failed'),
        ),
      );
    });

    test('throws for invalid and non-object JSON-RPC responses', () async {
      final invalidJson = SurfpoolJsonRpcClient(
        url: Uri.parse('http://127.0.0.1:8899'),
        client: MockClient((_) async => http.Response('not json', 200)),
      );
      final nonObjectJson = SurfpoolJsonRpcClient(
        url: Uri.parse('http://127.0.0.1:8899'),
        client: MockClient((_) async => http.Response('[]', 200)),
      );

      await expectLater(
        invalidJson.call('getHealth'),
        throwsA(
          isA<SurfpoolRpcException>()
              .having(
                (error) => error.message,
                'message',
                'Invalid JSON-RPC response',
              )
              .having((error) => error.cause, 'cause', isA<FormatException>()),
        ),
      );
      await expectLater(
        nonObjectJson.call('getHealth'),
        throwsA(
          isA<SurfpoolRpcException>().having(
            (error) => error.message,
            'message',
            'JSON-RPC response must be an object',
          ),
        ),
      );
    });

    test('throws for JSON-RPC error payloads without codes', () async {
      Future<void> expectError(Object? error, String message) async {
        final client = SurfpoolJsonRpcClient(
          url: Uri.parse('http://127.0.0.1:8899'),
          client: MockClient(
            (_) async => http.Response(
              jsonEncode(<String, Object?>{'error': error}),
              200,
            ),
          ),
        );

        await expectLater(
          client.call('getHealth'),
          throwsA(
            isA<SurfpoolRpcException>()
                .having((exception) => exception.rpcCode, 'rpcCode', isNull)
                .having((exception) => exception.message, 'message', message),
          ),
        );
      }

      await expectError(<String, Object?>{
        'message': null,
      }, 'Unknown RPC error');
      await expectError(<String, Object?>{'message': 'failed'}, 'failed');
      await expectError('failed', 'Unknown RPC error');
    });
  });
}
