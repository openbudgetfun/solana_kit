import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:test/test.dart';

void main() {
  group('getTimeoutPromise', () {
    test('pends for 30 seconds when the commitment is processed', () {
      fakeAsync((async) {
        var isCompleted = false;
        Object? caughtError;
        final abortController = CancellationTokenSource();

        unawaited(
          getTimeoutPromise(
            abortSignal: abortController.token,
            commitment: Commitment.processed,
          ).then<void>(
            (_) {
              isCompleted = true;
            },
            onError: (Object error) {
              caughtError = error;
            },
          ),
        );

        // Advance to 29.999 seconds - should still be pending.
        async.elapse(const Duration(milliseconds: 29999));
        expect(isCompleted, isFalse);
        expect(caughtError, isNull);

        // Advance 1 more millisecond - should now be timed out.
        async.elapse(const Duration(milliseconds: 1));
        expect(caughtError, isNotNull);

        abortController.cancel();
      });
    });

    test('pends for 60 seconds when the commitment is confirmed', () {
      fakeAsync((async) {
        Object? caughtError;
        final abortController = CancellationTokenSource();

        unawaited(
          getTimeoutPromise(
            abortSignal: abortController.token,
            commitment: Commitment.confirmed,
          ).then<void>(
            (_) {},
            onError: (Object error) {
              caughtError = error;
            },
          ),
        );

        // Advance to 59.999 seconds - should still be pending.
        async.elapse(const Duration(milliseconds: 59999));
        expect(caughtError, isNull);

        // Advance 1 more millisecond - should now be timed out.
        async.elapse(const Duration(milliseconds: 1));
        expect(caughtError, isNotNull);

        abortController.cancel();
      });
    });

    test('pends for 60 seconds when the commitment is finalized', () {
      fakeAsync((async) {
        Object? caughtError;
        final abortController = CancellationTokenSource();

        unawaited(
          getTimeoutPromise(
            abortSignal: abortController.token,
            commitment: Commitment.finalized,
          ).then<void>(
            (_) {},
            onError: (Object error) {
              caughtError = error;
            },
          ),
        );

        // Advance to 59.999 seconds - should still be pending.
        async.elapse(const Duration(milliseconds: 59999));
        expect(caughtError, isNull);

        // Advance 1 more millisecond - should now be timed out.
        async.elapse(const Duration(milliseconds: 1));
        expect(caughtError, isNotNull);

        abortController.cancel();
      });
    });

    test('throws a StateError when aborted before the timeout', () {
      fakeAsync((async) {
        Object? caughtError;
        final abortController = CancellationTokenSource();

        unawaited(
          getTimeoutPromise(
            abortSignal: abortController.token,
            commitment: Commitment.finalized,
          ).then<void>(
            (_) {},
            onError: (Object error) {
              caughtError = error;
            },
          ),
        );

        abortController.cancel('test abort');
        async.elapse(Duration.zero);

        expect(caughtError, isA<StateError>());
        expect(
          (caughtError! as StateError).message,
          contains('operation was aborted'),
        );
      });
    });

    test('throws immediately when abortSignal is already aborted', () {
      final abortController = CancellationTokenSource()..cancel('pre-abort');

      expect(
        () => getTimeoutPromise(
          abortSignal: abortController.token,
          commitment: Commitment.processed,
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('operation was aborted'),
          ),
        ),
      );
    });
  });
}
