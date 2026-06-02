import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('TransactionsClient.broadcastTransaction', () {
    test('sends POST to sender URL and returns signature', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'sendTransaction');
        expect(body['jsonrpc'], '2.0');
        final params = body['params']! as List<Object?>;
        expect(params[0], 'base64-encoded-tx');
        final options = params[1]! as Map<String, Object?>;
        expect(options, {
          'encoding': 'base64',
          'skipPreflight': true,
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
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final signature = await helius.transactions.broadcastTransaction(
        const BroadcastTransactionRequest(transaction: 'base64-encoded-tx'),
      );

      expect(signature, 'sig-123');
    });

    test('handles a bare-string JSON response', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode('sig-bare'), 200);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final signature = await helius.transactions.broadcastTransaction(
        const BroadcastTransactionRequest(transaction: 'base64-encoded-tx'),
      );

      expect(signature, 'sig-bare');
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
