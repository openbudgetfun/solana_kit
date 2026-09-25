import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('isRetryableError', () {
    test('retries network errors and 5xx but not 4xx', () {
      expect(isRetryableError(Exception('network')), isTrue);
      expect(
        isRetryableError(
          createSolanaError(
            SolanaErrorCode.heliusRestError,
            context: {SolanaErrorContextKeys.statusCode: 503},
          ),
        ),
        isTrue,
      );
      expect(
        isRetryableError(
          createSolanaError(
            SolanaErrorCode.heliusRestError,
            context: {SolanaErrorContextKeys.statusCode: 400},
          ),
        ),
        isFalse,
      );
    });
  });

  group('retryWithBackoff', () {
    test('returns immediately on success', () async {
      expect(
        await retryWithBackoff(() async => 'ok', sleep: (_) async {}),
        'ok',
      );
    });

    test('retries retryable errors until success', () async {
      var calls = 0;
      final result = await retryWithBackoff(() async {
        calls++;
        if (calls < 3) throw Exception('temporary');
        return 'ok';
      }, sleep: (_) async {});

      expect(result, 'ok');
      expect(calls, 3);
    });

    test('does not retry non-retryable HTTP errors', () async {
      var calls = 0;
      final error = createSolanaError(
        SolanaErrorCode.heliusRestError,
        context: {SolanaErrorContextKeys.statusCode: 409},
      );

      await expectLater(
        retryWithBackoff(() async {
          calls++;
          throw error;
        }, sleep: (_) async {}),
        throwsA(same(error)),
      );
      expect(calls, 1);
    });

    test('throws the final retryable error after max retries', () async {
      var calls = 0;
      await expectLater(
        retryWithBackoff(
          () async {
            calls++;
            throw Exception('still down');
          },
          maxRetries: 2,
          sleep: (_) async {},
        ),
        throwsA(isA<Exception>()),
      );
      expect(calls, 2);
    });
  });
}
