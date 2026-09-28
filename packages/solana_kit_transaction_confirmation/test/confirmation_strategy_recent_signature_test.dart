import 'dart:async';

import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:test/test.dart';

void main() {
  group('createRecentSignatureConfirmationPromiseFactory', () {
    late Completer<List<SignatureStatus?>> getSignatureStatusesCompleter;
    late void Function({required Object? err, required bool received})?
    signatureNotificationCallback;
    late Future<void> Function({
      required CancellationToken abortSignal,
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
              getSignatureStatuses: (signatures, {required abortSignal}) {
                return getSignatureStatusesCompleter.future;
              },
              onSignatureNotification:
                  (
                    signature, {
                    required commitment,
                    required abortSignal,
                    required void Function({
                      required Object? err,
                      required bool received,
                    })
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
        abortSignal: CancellationTokenSource().token,
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
        abortSignal: CancellationTokenSource().token,
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
              abortSignal: CancellationTokenSource().token,
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
              abortSignal: CancellationTokenSource().token,
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
          abortSignal: CancellationTokenSource().token,
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
        abortSignal: CancellationTokenSource().token,
        commitment: Commitment.finalized,
        signature: 'abc',
      );

      // Give microtasks a chance to set up the subscription.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Now trigger the subscription notification.
      signatureNotificationCallback!(err: null, received: false);

      await future;
    });

    test('a received-notification cannot resolve the confirmation', () async {
      final future = getSignatureConfirmationPromise(
        abortSignal: CancellationTokenSource().token,
        commitment: Commitment.finalized,
        signature: 'abc',
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // The node received the signature but has not executed it; this must
      // not be mistaken for confirmation.
      signatureNotificationCallback!(err: null, received: true);
      expect(
        await future
            .then<Object?>((_) => 'confirmed')
            .timeout(
              const Duration(milliseconds: 50),
              onTimeout: () => 'pending',
            ),
        'pending',
      );

      // The processed-status notification is what confirms.
      signatureNotificationCallback!(err: null, received: false);
      await future;
    });

    test('a received-notification cannot fail the confirmation', () async {
      final future = getSignatureConfirmationPromise(
        abortSignal: CancellationTokenSource().token,
        commitment: Commitment.finalized,
        signature: 'abc',
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      signatureNotificationCallback!(err: 'o no', received: true);
      expect(
        await future
            .then<Object?>((_) => 'confirmed')
            .timeout(
              const Duration(milliseconds: 50),
              onTimeout: () => 'pending',
            ),
        'pending',
      );

      // The transaction is still confirmed by a status notification.
      signatureNotificationCallback!(err: null, received: false);
      await future;
    });

    test('fatals when the signature subscription returns an error', () async {
      final future = getSignatureConfirmationPromise(
        abortSignal: CancellationTokenSource().token,
        commitment: Commitment.finalized,
        signature: 'abc',
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      signatureNotificationCallback!(err: 'o no', received: false);

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
      CancellationToken? capturedCancellationToken;

      final confirmationFn = createRecentSignatureConfirmationPromiseFactory(
        RecentSignatureConfirmationConfig(
          getSignatureStatuses: (signatures, {required abortSignal}) {
            capturedCancellationToken = abortSignal;
            return Completer<List<SignatureStatus?>>().future;
          },
          onSignatureNotification:
              (
                signature, {
                required commitment,
                required abortSignal,
                required void Function({
                  required Object? err,
                  required bool received,
                })
                onNotification,
              }) async {
                await Completer<void>().future;
              },
        ),
      );

      final callerCancellationTokenSource = CancellationTokenSource();
      unawaited(
        confirmationFn(
          abortSignal: callerCancellationTokenSource.token,
          commitment: Commitment.finalized,
          signature: 'abc',
        ).catchError((_) {}),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(capturedCancellationToken, isNotNull);
      expect(capturedCancellationToken!.isCancelled, isFalse);

      callerCancellationTokenSource.cancel('test');
      await Future<void>.delayed(Duration.zero);

      expect(capturedCancellationToken!.isCancelled, isTrue);
    });

    test('fatals when the getSignatureStatuses call throws an error', () async {
      final fn = createRecentSignatureConfirmationPromiseFactory(
        RecentSignatureConfirmationConfig(
          getSignatureStatuses: (signatures, {required abortSignal}) async {
            throw StateError('rpc failure');
          },
          onSignatureNotification:
              (
                signature, {
                required commitment,
                required abortSignal,
                required void Function({
                  required Object? err,
                  required bool received,
                })
                onNotification,
              }) async {
                await Completer<void>().future;
              },
        ),
      );

      await expectLater(
        fn(
          abortSignal: CancellationTokenSource().token,
          commitment: Commitment.finalized,
          signature: 'abc',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            equals('rpc failure'),
          ),
        ),
      );
    });
  });
}
