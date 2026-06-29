import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:test/test.dart';

void main() {
  group('createNonceInvalidationPromiseFactory', () {
    late Completer<NonceAccountInfo?> getNonceAccountCompleter;
    late void Function({required String nonceValue})?
    accountNotificationCallback;
    late Future<Never> Function({
      required CancellationToken abortSignal,
      required Commitment commitment,
      required String expectedNonceValue,
      required String nonceAccountAddress,
    })
    getNonceInvalidationPromise;

    setUp(() {
      getNonceAccountCompleter = Completer<NonceAccountInfo?>();
      accountNotificationCallback = null;

      getNonceInvalidationPromise = createNonceInvalidationPromiseFactory(
        NonceInvalidationConfig(
          getNonceAccount:
              (
                nonceAccountAddress, {
                required abortSignal,
                required commitment,
              }) {
                return getNonceAccountCompleter.future;
              },
          onAccountNotification:
              (
                nonceAccountAddress, {
                required abortSignal,
                required commitment,
                required void Function({required String nonceValue})
                onNotification,
              }) async {
                accountNotificationCallback = onNotification;
                // Keep subscription open.
                await Completer<void>().future;
              },
        ),
      );
    });

    test('continues to pend when the nonce value returned by the one-shot '
        'query is the same as the expected one', () async {
      getNonceAccountCompleter.complete(
        const NonceAccountInfo(nonceValue: 'expected_nonce'),
      );

      final completer = Completer<String>();
      unawaited(
        getNonceInvalidationPromise(
              abortSignal: CancellationTokenSource().token,
              commitment: Commitment.finalized,
              expectedNonceValue: 'expected_nonce',
              nonceAccountAddress: 'nonce_address',
            )
            .then<String>((_) {
              completer.complete('resolved');
              return 'resolved';
            })
            .catchError((Object error) {
              completer.complete('rejected');
              return 'rejected';
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

    test('fatals when the nonce account is not found', () async {
      getNonceAccountCompleter.complete(null);

      await expectLater(
        getNonceInvalidationPromise(
          abortSignal: CancellationTokenSource().token,
          commitment: Commitment.finalized,
          expectedNonceValue: 'expected_nonce',
          nonceAccountAddress: 'nonce_address',
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.nonceAccountNotFound),
          ),
        ),
      );
    });

    test('fatals when the nonce value returned by the one-shot query is '
        'different than the expected one', () async {
      getNonceAccountCompleter.complete(
        const NonceAccountInfo(nonceValue: 'different_nonce'),
      );

      await expectLater(
        getNonceInvalidationPromise(
          abortSignal: CancellationTokenSource().token,
          commitment: Commitment.finalized,
          expectedNonceValue: 'expected_nonce',
          nonceAccountAddress: 'nonce_address',
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.invalidNonce),
          ),
        ),
      );
    });

    test('continues to pend when the nonce value returned by the '
        'account subscription is the same as expected', () async {
      // Don't resolve the one-shot query.

      final completer = Completer<String>();
      unawaited(
        getNonceInvalidationPromise(
              abortSignal: CancellationTokenSource().token,
              commitment: Commitment.finalized,
              expectedNonceValue: 'expected_nonce',
              nonceAccountAddress: 'nonce_address',
            )
            .then<String>((_) {
              completer.complete('resolved');
              return 'resolved';
            })
            .catchError((Object error) {
              completer.complete('rejected');
              return 'rejected';
            }),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Trigger subscription notification with matching nonce.
      accountNotificationCallback!(nonceValue: 'expected_nonce');

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

    test('fatals when the nonce value returned by the account subscription '
        'is different than the expected one', () async {
      final future = getNonceInvalidationPromise(
        abortSignal: CancellationTokenSource().token,
        commitment: Commitment.finalized,
        expectedNonceValue: 'expected_nonce',
        nonceAccountAddress: 'nonce_address',
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      accountNotificationCallback!(nonceValue: 'different_nonce');

      await expectLater(
        future,
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.invalidNonce),
          ),
        ),
      );
    });

    test('aborts internal abort controller when caller aborts', () async {
      CancellationToken? capturedCancellationToken;

      final fn = createNonceInvalidationPromiseFactory(
        NonceInvalidationConfig(
          getNonceAccount:
              (
                nonceAccountAddress, {
                required abortSignal,
                required commitment,
              }) {
                capturedCancellationToken = abortSignal;
                return Completer<NonceAccountInfo?>().future;
              },
          onAccountNotification:
              (
                nonceAccountAddress, {
                required abortSignal,
                required commitment,
                required void Function({required String nonceValue})
                onNotification,
              }) async {
                await Completer<void>().future;
              },
        ),
      );

      final callerCancellationTokenSource = CancellationTokenSource();
      unawaited(
        fn(
          abortSignal: callerCancellationTokenSource.token,
          commitment: Commitment.finalized,
          expectedNonceValue: 'expected_nonce',
          nonceAccountAddress: 'nonce_address',
        ).then<void>((_) {}).catchError((_) {}),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(capturedCancellationToken, isNotNull);
      expect(capturedCancellationToken!.isCancelled, isFalse);

      callerCancellationTokenSource.cancel('test');
      await Future<void>.delayed(Duration.zero);

      expect(capturedCancellationToken!.isCancelled, isTrue);
    });

    test('passes commitment to the nonce account getter', () async {
      Commitment? capturedCommitment;

      final fn = createNonceInvalidationPromiseFactory(
        NonceInvalidationConfig(
          getNonceAccount:
              (
                nonceAccountAddress, {
                required abortSignal,
                required commitment,
              }) async {
                capturedCommitment = commitment;
                return null;
              },
          onAccountNotification:
              (
                nonceAccountAddress, {
                required abortSignal,
                required commitment,
                required void Function({required String nonceValue})
                onNotification,
              }) async {
                await Completer<void>().future;
              },
        ),
      );

      try {
        await fn(
          abortSignal: CancellationTokenSource().token,
          commitment: Commitment.confirmed,
          expectedNonceValue: 'expected_nonce',
          nonceAccountAddress: 'nonce_address',
        );
      } on SolanaError catch (_) {
        // Expected - nonce account not found.
      }

      expect(capturedCommitment, equals(Commitment.confirmed));
    });

    test('fatals when the getNonceAccount call throws an error', () async {
      final fn = createNonceInvalidationPromiseFactory(
        NonceInvalidationConfig(
          getNonceAccount:
              (
                nonceAccountAddress, {
                required abortSignal,
                required commitment,
              }) async {
                throw StateError('rpc failure');
              },
          onAccountNotification:
              (
                nonceAccountAddress, {
                required abortSignal,
                required commitment,
                required void Function({required String nonceValue})
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
          expectedNonceValue: 'expected_nonce',
          nonceAccountAddress: 'nonce_address',
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

    test(
      'passes address and commitment to the account notification subscriber',
      () async {
        String? capturedAddress;
        Commitment? capturedCommitment;

        final fn = createNonceInvalidationPromiseFactory(
          NonceInvalidationConfig(
            getNonceAccount:
                (
                  nonceAccountAddress, {
                  required abortSignal,
                  required commitment,
                }) {
                  return Completer<NonceAccountInfo?>().future;
                },
            onAccountNotification:
                (
                  nonceAccountAddress, {
                  required abortSignal,
                  required commitment,
                  required void Function({required String nonceValue})
                  onNotification,
                }) async {
                  capturedAddress = nonceAccountAddress;
                  capturedCommitment = commitment;
                  await Completer<void>().future;
                },
          ),
        );

        unawaited(
          fn(
            abortSignal: CancellationTokenSource().token,
            commitment: Commitment.finalized,
            expectedNonceValue: 'expected_nonce',
            nonceAccountAddress: 'my_nonce_address',
          ).then<void>((_) {}).catchError((_) {}),
        );

        await Future<void>.delayed(Duration.zero);

        expect(capturedAddress, equals('my_nonce_address'));
        expect(capturedCommitment, equals(Commitment.finalized));
      },
    );
  });
}
