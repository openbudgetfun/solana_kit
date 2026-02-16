import 'dart:async';

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:test/test.dart';

void main() {
  group('raceStrategies', () {
    test('aborts the AbortSignal passed to '
        'getRecentSignatureConfirmationPromise when finished', () async {
      AbortSignal? capturedSignal;

      await raceStrategies(
        'abc',
        BaseTransactionConfirmationStrategyConfig(
          commitment: Commitment.finalized,
          getRecentSignatureConfirmationPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
                required String signature,
              }) {
                capturedSignal = abortSignal;
                return Future.value();
              },
        ),
        ({required AbortSignal abortSignal}) => [],
      );

      // After completion, the internal abort controller should be aborted.
      expect(capturedSignal, isNotNull);
      expect(capturedSignal!.isAborted, isTrue);
    });

    test(
      'aborts the AbortSignal passed to '
      'getRecentSignatureConfirmationPromise when the caller aborts',
      () async {
        AbortSignal? capturedSignal;
        final callerAbortController = AbortController();

        final future = raceStrategies(
          'abc',
          BaseTransactionConfirmationStrategyConfig(
            abortSignal: callerAbortController.signal,
            commitment: Commitment.finalized,
            getRecentSignatureConfirmationPromise:
                ({
                  required AbortSignal abortSignal,
                  required Commitment commitment,
                  required String signature,
                }) {
                  capturedSignal = abortSignal;
                  // Never resolve.
                  return Completer<void>().future;
                },
          ),
          ({required AbortSignal abortSignal}) => [
            // Also never resolve.
            Completer<void>().future,
          ],
        );

        // Signal should not be aborted yet.
        expect(capturedSignal, isNotNull);
        expect(capturedSignal!.isAborted, isFalse);

        callerAbortController.abort('test');

        // Give microtask queue a chance to process.
        await Future<void>.delayed(Duration.zero);

        expect(capturedSignal!.isAborted, isTrue);

        // The future should eventually settle.
        // We don't await it since nothing resolves the inner completers,
        // but that's fine - the test verifies the abort propagation.
        unawaited(future.catchError((_) {}));
      },
    );

    test(
      'aborts the AbortSignal passed to specific strategies when finished',
      () async {
        AbortSignal? capturedStrategySignal;

        await raceStrategies(
          'abc',
          BaseTransactionConfirmationStrategyConfig(
            commitment: Commitment.finalized,
            getRecentSignatureConfirmationPromise:
                ({
                  required AbortSignal abortSignal,
                  required Commitment commitment,
                  required String signature,
                }) {
                  return Future.value();
                },
          ),
          ({required AbortSignal abortSignal}) {
            capturedStrategySignal = abortSignal;
            return [];
          },
        );

        expect(capturedStrategySignal, isNotNull);
        expect(capturedStrategySignal!.isAborted, isTrue);
      },
    );

    test('aborts the AbortSignal passed to specific strategies '
        'when the caller aborts', () async {
      AbortSignal? capturedStrategySignal;
      final callerAbortController = AbortController();

      final future = raceStrategies(
        'abc',
        BaseTransactionConfirmationStrategyConfig(
          abortSignal: callerAbortController.signal,
          commitment: Commitment.finalized,
          getRecentSignatureConfirmationPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
                required String signature,
              }) {
                return Completer<void>().future;
              },
        ),
        ({required AbortSignal abortSignal}) {
          capturedStrategySignal = abortSignal;
          return [Completer<void>().future];
        },
      );

      expect(capturedStrategySignal, isNotNull);
      expect(capturedStrategySignal!.isAborted, isFalse);

      callerAbortController.abort('test');

      await Future<void>.delayed(Duration.zero);

      expect(capturedStrategySignal!.isAborted, isTrue);

      unawaited(future.catchError((_) {}));
    });

    test('propagates strategy rejection', () async {
      final future = raceStrategies(
        'abc',
        BaseTransactionConfirmationStrategyConfig(
          commitment: Commitment.finalized,
          getRecentSignatureConfirmationPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
                required String signature,
              }) {
                return Completer<void>().future;
              },
        ),
        ({required AbortSignal abortSignal}) => [
          Future.error(StateError('strategy failed')),
        ],
      );

      await expectLater(future, throwsA(isA<StateError>()));
    });

    test('propagates signature confirmation resolution', () async {
      await raceStrategies(
        'abc',
        BaseTransactionConfirmationStrategyConfig(
          commitment: Commitment.finalized,
          getRecentSignatureConfirmationPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
                required String signature,
              }) {
                return Future.value();
              },
        ),
        ({required AbortSignal abortSignal}) => [Completer<void>().future],
      );
      // If we reach here, it resolved successfully.
    });

    test('throws when the signal is already aborted', () async {
      final abortController = AbortController()..abort();

      await expectLater(
        raceStrategies(
          'abc',
          BaseTransactionConfirmationStrategyConfig(
            abortSignal: abortController.signal,
            commitment: Commitment.finalized,
            getRecentSignatureConfirmationPromise:
                ({
                  required AbortSignal abortSignal,
                  required Commitment commitment,
                  required String signature,
                }) {
                  return Completer<void>().future;
                },
          ),
          ({required AbortSignal abortSignal}) => [],
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
