import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('TransactionsClient.pollTransactionConfirmation', () {
    test('returns confirmed result on first poll', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getSignatureStatuses');
        expect(body['jsonrpc'], '2.0');
        final params = body['params'] as List<Object?>;
        final signatures = params[0] as List<Object?>;
        expect(signatures, contains('sig-poll'));
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': <String, Object?>{
              'value': <Object?>[
                <String, Object?>{
                  'confirmationStatus': 'confirmed',
                  'err': null,
                },
              ],
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final result = await helius.transactions.pollTransactionConfirmation(
        PollTransactionConfirmationRequest(
          signature: 'sig-poll',
          timeoutMs: 10000,
          intervalMs: 100,
        ),
      );

      expect(result.signature, 'sig-poll');
      expect(result.confirmationStatus, 'confirmed');
    });

    test('times out when status is never confirmed', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': <String, Object?>{
              'value': <Object?>[null],
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.transactions.pollTransactionConfirmation(
          PollTransactionConfirmationRequest(
            signature: 'sig-timeout',
            timeoutMs: 500,
            intervalMs: 100,
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
