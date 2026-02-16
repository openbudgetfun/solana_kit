import 'dart:async';

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:test/test.dart';

void main() {
  group('createRecentSignatureConfirmationPromiseFactory', () {
    late Completer<List<SignatureStatus?>> getSignatureStatusesCompleter;
    late void Function({required Object? err})? signatureNotificationCallback;
    late Future<void> Function({
      required AbortSignal abortSignal,
      required Commitment commitment,
      required String signature,
    })
    getSignatureConfirmationPromise;

    setUp(() {
      getSignatureStatusesCompleter = Completer<List<SignatureStatus?>>();
      signatureNotificationCallback = null;

      getSignatureConfirmationPromise =
          createRecentSignatureConfirmationPromiseFactory(
            RecentSignatureConfirmationConfig(
              getSignatureStatuses:
                  (
                    List<String> signatures, {
                    required AbortSignal abortSignal,
                  }) {
                    return getSignatureStatusesCompleter.future;
                  },
              onSignatureNotification:
                  (
                    String signature, {
                    required Commitment commitment,
                    required AbortSignal abortSignal,
                    required void Function({required Object? err})
                    onNotification,
                  }) async {
                    signatureNotificationCallback = onNotification;
                    // Never resolve (keeps subscription open).
                    await Completer<void>().future;
                  },
            ),
          );
    });

    test('resolves when the signature status returned by the one-shot query '
        'is at the target level of commitment', () async {
      getSignatureStatusesCompleter.complete([
        const SignatureStatus(confirmationStatus: Commitment.finalized),
      ]);

      await getSignatureConfirmationPromise(
        abortSignal: AbortController().signal,
        commitment: Commitment.finalized,
        signature: 'abc',
      );
      // If we get here, the promise resolved.
    });

    test('resolves when the signature status returned by the one-shot query '
        'exceeds the target commitment', () async {
      getSignatureStatusesCompleter.complete([
        const SignatureStatus(confirmationStatus: Commitment.finalized),
      ]);

      await getSignatureConfirmationPromise(
        abortSignal: AbortController().signal,
        commitment: Commitment.confirmed,
        signature: 'abc',
      );
    });

    test('continues to pend when the signature status returned by '
        'the one-shot query is at a lower level of commitment', () async {
      getSignatureStatusesCompleter.complete([
        const SignatureStatus(confirmationStatus: Commitment.processed),
      ]);

      final completer = Completer<String>();
      unawaited(
        getSignatureConfirmationPromise(
              abortSignal: AbortController().signal,
              commitment: Commitment.finalized,
              signature: 'abc',
            )
            .then((_) {
              completer.complete('resolved');
            })
            .catchError((Object error) {
              completer.complete('rejected');
            }),
      );

      // Give microtasks a chance to process.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // The promise should still be pending.
      final result = await Future.any([
        completer.future,
        Future<String>.delayed(
          const Duration(milliseconds: 50),
          () => 'pending',
        ),
      ]);
      expect(result, equals('pending'));
    });

    test('continues to pend when no signature status is returned by '
        'the one-shot query', () async {
      getSignatureStatusesCompleter.complete([null]);

      final completer = Completer<String>();
      unawaited(
        getSignatureConfirmationPromise(
              abortSignal: AbortController().signal,
              commitment: Commitment.finalized,
              signature: 'abc',
            )
            .then((_) {
              completer.complete('resolved');
            })
            .catchError((Object error) {
              completer.complete('rejected');
            }),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final result = await Future.any([
        completer.future,
        Future<String>.delayed(
          const Duration(milliseconds: 50),
          () => 'pending',
        ),
      ]);
      expect(result, equals('pending'));
    });

    test('fatals when the signature status returned by the one-shot query '
        'is an error', () async {
      getSignatureStatusesCompleter.complete([
        const SignatureStatus(
          confirmationStatus: Commitment.finalized,
          err: 'o no',
        ),
      ]);

      await expectLater(
        getSignatureConfirmationPromise(
          abortSignal: AbortController().signal,
          commitment: Commitment.finalized,
          signature: 'abc',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Transaction failed'),
          ),
        ),
      );
    });

    test('resolves when a signature notification indicates success', () async {
      // Don't resolve the one-shot query.

      final future = getSignatureConfirmationPromise(
        abortSignal: AbortController().signal,
        commitment: Commitment.finalized,
        signature: 'abc',
      );

      // Give microtasks a chance to set up the subscription.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Now trigger the subscription notification.
      signatureNotificationCallback!(err: null);

      await future;
    });

    test('fatals when the signature subscription returns an error', () async {
      final future = getSignatureConfirmationPromise(
        abortSignal: AbortController().signal,
        commitment: Commitment.finalized,
        signature: 'abc',
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      signatureNotificationCallback!(err: 'o no');

      await expectLater(
        future,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Transaction failed'),
          ),
        ),
      );
    });

    test('aborts internal abort controller when caller aborts', () async {
      AbortSignal? capturedAbortSignal;

      final confirmationFn = createRecentSignatureConfirmationPromiseFactory(
        RecentSignatureConfirmationConfig(
          getSignatureStatuses:
              (List<String> signatures, {required AbortSignal abortSignal}) {
                capturedAbortSignal = abortSignal;
                return Completer<List<SignatureStatus?>>().future;
              },
          onSignatureNotification:
              (
                String signature, {
                required Commitment commitment,
                required AbortSignal abortSignal,
                required void Function({required Object? err}) onNotification,
              }) async {
                await Completer<void>().future;
              },
        ),
      );

      final callerAbortController = AbortController();
      unawaited(
        confirmationFn(
          abortSignal: callerAbortController.signal,
          commitment: Commitment.finalized,
          signature: 'abc',
        ).catchError((_) {}),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(capturedAbortSignal, isNotNull);
      expect(capturedAbortSignal!.isAborted, isFalse);

      callerAbortController.abort('test');
      await Future<void>.delayed(Duration.zero);

      expect(capturedAbortSignal!.isAborted, isTrue);
    });
  });
}
