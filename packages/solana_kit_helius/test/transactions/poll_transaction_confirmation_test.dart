import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('TransactionsClient.pollTransactionConfirmation', () {
    for (final status in ['processed', 'confirmed', 'finalized']) {
      test('rejects a failed transaction at $status commitment', () async {
        final helius = createHelius(
          HeliusConfig(apiKey: 'test-key'),
          client: _statusClient(
            status,
            error: {
              'InstructionError': [0, 'InsufficientFunds'],
            },
          ),
        );

        await expectLater(
          helius.transactions.pollTransactionConfirmation(
            const PollTransactionConfirmationRequest(
              signature: 'failed-payment',
              timeoutMs: 50,
              intervalMs: 1,
            ),
          ),
          throwsA(
            isA<SolanaError>().having(
              (error) => error.code,
              'code',
              SolanaErrorCode.instructionErrorInsufficientFunds,
            ),
          ),
        );
      });
    }

    test('accepts confirmed when processed commitment was requested', () async {
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: _statusClient('confirmed'),
      );

      final result = await helius.transactions.pollTransactionConfirmation(
        const PollTransactionConfirmationRequest(
          signature: 'already-confirmed',
          commitment: CommitmentLevel.processed,
          timeoutMs: 50,
          intervalMs: 1,
        ),
      );

      expect(result.confirmationStatus, 'confirmed');
    });

    test('does not accept processed when confirmed is required', () async {
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: _statusClient('processed'),
      );

      await expectLater(
        helius.transactions.pollTransactionConfirmation(
          const PollTransactionConfirmationRequest(
            signature: 'not-confirmed',
            timeoutMs: 20,
            intervalMs: 1,
          ),
        ),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            SolanaErrorCode.heliusTransactionConfirmationTimeout,
          ),
        ),
      );
    });

    test('returns confirmed result on first poll', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getSignatureStatuses');
        expect(body['jsonrpc'], '2.0');
        final params = body['params']! as List<Object?>;
        final signatures = params[0]! as List<Object?>;
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
        const PollTransactionConfirmationRequest(
          signature: 'sig-poll',
          timeoutMs: 10000,
          intervalMs: 100,
        ),
      );

      expect(result.signature, 'sig-poll');
      expect(result.confirmationStatus, 'confirmed');
    });

    test('uses default polling options and accepts finalized status', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': <String, Object?>{
              'value': <Object?>[
                <String, Object?>{
                  'confirmationStatus': 'finalized',
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
        const PollTransactionConfirmationRequest(signature: 'sig-finalized'),
      );

      expect(result.signature, 'sig-finalized');
      expect(result.confirmationStatus, 'finalized');
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
          const PollTransactionConfirmationRequest(
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

MockClient _statusClient(String status, {Object? error}) => MockClient((
  request,
) async {
  final body = jsonDecode(request.body) as Map<String, Object?>;

  return http.Response(
    jsonEncode({
      'jsonrpc': '2.0',
      'id': body['id'],
      'result': {
        'value': [
          {'confirmationStatus': status, 'err': error},
        ],
      },
    }),
    200,
  );
});
