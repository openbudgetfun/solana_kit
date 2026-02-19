import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('TransactionsClient.sendTransactionWithSender', () {
    test(
      'sends POST to sender with base64 encoding and returns signature',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['method'], 'sendTransaction');
          expect(body['jsonrpc'], '2.0');
          final params = body['params']! as List<Object?>;
          expect(params[0], 'base64-tx-data');
          final options = params[1]! as Map<String, Object?>;
          expect(options['encoding'], 'base64');
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'result': 'sig-sender',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          const HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final signature = await helius.transactions.sendTransactionWithSender(
          const BroadcastTransactionRequest(transaction: 'base64-tx-data'),
        );

        expect(signature, 'sig-sender');
      },
    );

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Service Unavailable', 503);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.transactions.sendTransactionWithSender(
          const BroadcastTransactionRequest(transaction: 'bad-tx'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
