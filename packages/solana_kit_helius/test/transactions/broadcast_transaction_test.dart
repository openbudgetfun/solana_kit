import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('TransactionsClient.broadcastTransaction', () {
    test('submits, tracks confirmation, and returns the signature', () async {
      final client = MockClient((request) async {
        if (request.url.host == 'mainnet.helius-rpc.com') {
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['method'], 'sendTransaction');
          expect(body['jsonrpc'], '2.0');
          final params = body['params']! as List<Object?>;
          expect(params[0], 'base64-encoded-tx');
          final options = params[1]! as Map<String, Object?>;
          expect(options, {
            'encoding': 'base64',
            'skipPreflight': true,
            'preflightCommitment': 'confirmed',
            'maxRetries': 0,
          });
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'result': 'sig-123',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return _rpcResponse(request, (method) {
          switch (method) {
            case 'getLatestBlockhash':
              return {
                'value': {
                  'blockhash': 'hash',
                  'lastValidBlockHeight': 1000,
                },
              };
            case 'getBlockHeight':
              return 500;
            case 'getSignatureStatuses':
              return {
                'value': [
                  {'confirmationStatus': 'confirmed', 'err': null},
                ],
              };
          }

          throw StateError('unexpected RPC method $method');
        });
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final signature = await helius.transactions.broadcastTransaction(
        const BroadcastTransactionRequest(transaction: 'base64-encoded-tx'),
        options: const BroadcastTransactionOptions(pollIntervalMs: 1),
      );

      expect(signature, 'sig-123');
    });

    test('handles a bare-string JSON response', () async {
      final client = MockClient((request) async {
        if (request.url.host == 'mainnet.helius-rpc.com') {
          return http.Response(jsonEncode('sig-bare'), 200);
        }

        return _rpcResponse(request, (method) {
          switch (method) {
            case 'getLatestBlockhash':
              return {
                'value': {'blockhash': 'hash', 'lastValidBlockHeight': 1000},
              };
            case 'getBlockHeight':
              return 500;
            case 'getSignatureStatuses':
              return {
                'value': [
                  {'confirmationStatus': 'confirmed', 'err': null},
                ],
              };
          }

          throw StateError('unexpected RPC method $method');
        });
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final signature = await helius.transactions.broadcastTransaction(
        const BroadcastTransactionRequest(transaction: 'base64-encoded-tx'),
        options: const BroadcastTransactionOptions(pollIntervalMs: 1),
      );

      expect(signature, 'sig-bare');
    });

    test('re-checks status after the expiry height before giving up', () async {
      var heightReads = 0;
      var statusReads = 0;
      final client = MockClient((request) async {
        if (request.url.host == 'mainnet.helius-rpc.com') {
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'result': 'sig-123',
            }),
            200,
          );
        }

        return _rpcResponse(request, (method) {
          switch (method) {
            case 'getLatestBlockhash':
              return {
                'value': {'blockhash': 'hash', 'lastValidBlockHeight': 1000},
              };
            case 'getBlockHeight':
              return ++heightReads == 1 ? 500 : 1000;
            case 'getSignatureStatuses':
              statusReads++;
              return {
                'value': [
                  if (statusReads > 1)
                    {'confirmationStatus': 'confirmed', 'err': null}
                  else
                    null,
                ],
              };
          }

          throw StateError('unexpected RPC method $method');
        });
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final signature = await helius.transactions.broadcastTransaction(
        const BroadcastTransactionRequest(transaction: 'base64-encoded-tx'),
        options: const BroadcastTransactionOptions(
          lastValidBlockHeightOffset: 1,
          pollIntervalMs: 1,
        ),
      );

      expect(signature, 'sig-123');
      expect(statusReads, 2);
    });

    test('throws after the expiry re-check finds no landing', () async {
      final client = MockClient((request) async {
        if (request.url.host == 'mainnet.helius-rpc.com') {
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'result': 'sig-123',
            }),
            200,
          );
        }

        return _rpcResponse(request, (method) {
          switch (method) {
            case 'getLatestBlockhash':
              return {
                'value': {'blockhash': 'hash', 'lastValidBlockHeight': 500},
              };
            case 'getBlockHeight':
              return 1000;
            case 'getSignatureStatuses':
              return {
                'value': [null],
              };
          }

          throw StateError('unexpected RPC method $method');
        });
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.transactions.broadcastTransaction(
          const BroadcastTransactionRequest(transaction: 'base64-encoded-tx'),
          options: const BroadcastTransactionOptions(
            lastValidBlockHeightOffset: 1,
            pollIntervalMs: 1,
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Block height exceeded'),
          ),
        ),
      );
    });

    test('throws on JSON-RPC error object', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {'message': 'sender rejected transaction'},
          }),
          200,
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.transactions.broadcastTransaction(
          const BroadcastTransactionRequest(transaction: 'bad-tx'),
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('sender rejected transaction'),
          ),
        ),
      );
    });

    test('throws on malformed JSON-RPC success response', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode({'jsonrpc': '2.0'}), 200),
      );
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.transactions.broadcastTransaction(
          const BroadcastTransactionRequest(transaction: 'bad-tx'),
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Unexpected Sender response'),
          ),
        ),
      );
    });

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.transactions.broadcastTransaction(
          const BroadcastTransactionRequest(transaction: 'bad-tx'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}

http.Response _rpcResponse(
  http.Request request,
  Object? Function(String method) result,
) {
  final body = jsonDecode(request.body) as Map<String, Object?>;
  final method = body['method']! as String;

  return http.Response(
    jsonEncode({
      'jsonrpc': '2.0',
      'id': body['id'],
      'result': result(method),
    }),
    200,
  );
}
