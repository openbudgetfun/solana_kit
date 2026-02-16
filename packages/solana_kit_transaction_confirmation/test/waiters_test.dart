import 'dart:async';

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:test/test.dart';

void main() {
  group('waitForDurableNonceTransactionConfirmation', () {
    late Future<Never> Function({
      required AbortSignal abortSignal,
      required Commitment commitment,
      required String expectedNonceValue,
      required String nonceAccountAddress,
    })
    getNonceInvalidationPromise;
    late Future<void> Function({
      required AbortSignal abortSignal,
      required Commitment commitment,
      required String signature,
    })
    getRecentSignatureConfirmationPromise;

    late Completer<Never> nonceInvalidationCompleter;
    late Completer<void> signatureConfirmationCompleter;

    setUp(() {
      nonceInvalidationCompleter = Completer<Never>();
      signatureConfirmationCompleter = Completer<void>();

      getNonceInvalidationPromise =
          ({
            required AbortSignal abortSignal,
            required Commitment commitment,
            required String expectedNonceValue,
            required String nonceAccountAddress,
          }) {
            return nonceInvalidationCompleter.future;
          };

      getRecentSignatureConfirmationPromise =
          ({
            required AbortSignal abortSignal,
            required Commitment commitment,
            required String signature,
          }) {
            return signatureConfirmationCompleter.future;
          };
    });

    test('throws when the signal is already aborted', () async {
      final abortController = AbortController()..abort();

      await expectLater(
        waitForDurableNonceTransactionConfirmation(
          abortSignal: abortController.signal,
          commitment: Commitment.finalized,
          getNonceInvalidationPromise: getNonceInvalidationPromise,
          getRecentSignatureConfirmationPromise:
              getRecentSignatureConfirmationPromise,
          nonceAccountAddress: 'nonce_address',
          nonceValue: 'xyz',
          signature: 'test_signature',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('aborted'),
          ),
        ),
      );
    });

    test('resolves when the signature confirmation promise resolves '
        'despite the nonce invalidation promise having thrown', () async {
      // Complete the signature confirmation immediately.
      signatureConfirmationCompleter.complete();

      // Schedule the nonce error to fire asynchronously so the futures
      // are being listened to before the error occurs.
      Future<void>.delayed(Duration.zero, () {
        nonceInvalidationCompleter.completeError(StateError('o no'));
      }).ignore();

      await waitForDurableNonceTransactionConfirmation(
        abortSignal: AbortController().signal,
        commitment: Commitment.finalized,
        getNonceInvalidationPromise: getNonceInvalidationPromise,
        getRecentSignatureConfirmationPromise:
            getRecentSignatureConfirmationPromise,
        nonceAccountAddress: 'nonce_address',
        nonceValue: 'xyz',
        signature: 'test_signature',
      );
      // If we get here, it resolved successfully.
    });

    test('throws when the nonce invalidation promise throws', () async {
      nonceInvalidationCompleter.completeError(StateError('o no'));

      await expectLater(
        waitForDurableNonceTransactionConfirmation(
          abortSignal: AbortController().signal,
          commitment: Commitment.finalized,
          getNonceInvalidationPromise: getNonceInvalidationPromise,
          getRecentSignatureConfirmationPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
                required String signature,
              }) {
                return Completer<void>().future;
              },
          nonceAccountAddress: 'nonce_address',
          nonceValue: 'xyz',
          signature: 'test_signature',
        ),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', equals('o no')),
        ),
      );
    });

    test('throws when the signature confirmation promise throws', () async {
      signatureConfirmationCompleter.completeError(StateError('o no'));

      await expectLater(
        waitForDurableNonceTransactionConfirmation(
          abortSignal: AbortController().signal,
          commitment: Commitment.finalized,
          getNonceInvalidationPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
                required String expectedNonceValue,
                required String nonceAccountAddress,
              }) {
                return Completer<Never>().future;
              },
          getRecentSignatureConfirmationPromise:
              getRecentSignatureConfirmationPromise,
          nonceAccountAddress: 'nonce_address',
          nonceValue: 'xyz',
          signature: 'test_signature',
        ),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', equals('o no')),
        ),
      );
    });

    test(
      'calls getNonceInvalidationPromise with the necessary input',
      () async {
        String? capturedNonceValue;
        String? capturedNonceAddress;
        Commitment? capturedCommitment;

        unawaited(
          waitForDurableNonceTransactionConfirmation(
            abortSignal: AbortController().signal,
            commitment: Commitment.finalized,
            getNonceInvalidationPromise:
                ({
                  required AbortSignal abortSignal,
                  required Commitment commitment,
                  required String expectedNonceValue,
                  required String nonceAccountAddress,
                }) {
                  capturedNonceValue = expectedNonceValue;
                  capturedNonceAddress = nonceAccountAddress;
                  capturedCommitment = commitment;
                  return Completer<Never>().future;
                },
            getRecentSignatureConfirmationPromise:
                ({
                  required AbortSignal abortSignal,
                  required Commitment commitment,
                  required String signature,
                }) {
                  return Completer<void>().future;
                },
            nonceAccountAddress: 'my_nonce_address',
            nonceValue: 'xyz',
            signature: 'test_signature',
          ).catchError((_) {}),
        );

        await Future<void>.delayed(Duration.zero);

        expect(capturedNonceValue, equals('xyz'));
        expect(capturedNonceAddress, equals('my_nonce_address'));
        expect(capturedCommitment, equals(Commitment.finalized));
      },
    );

    test(
      'calls getRecentSignatureConfirmationPromise with the necessary input',
      () async {
        String? capturedSignature;
        Commitment? capturedCommitment;

        unawaited(
          waitForDurableNonceTransactionConfirmation(
            abortSignal: AbortController().signal,
            commitment: Commitment.finalized,
            getNonceInvalidationPromise:
                ({
                  required AbortSignal abortSignal,
                  required Commitment commitment,
                  required String expectedNonceValue,
                  required String nonceAccountAddress,
                }) {
                  return Completer<Never>().future;
                },
            getRecentSignatureConfirmationPromise:
                ({
                  required AbortSignal abortSignal,
                  required Commitment commitment,
                  required String signature,
                }) {
                  capturedSignature = signature;
                  capturedCommitment = commitment;
                  return Completer<void>().future;
                },
            nonceAccountAddress: 'nonce_address',
            nonceValue: 'xyz',
            signature: 'test_signature',
          ).catchError((_) {}),
        );

        await Future<void>.delayed(Duration.zero);

        expect(capturedSignature, equals('test_signature'));
        expect(capturedCommitment, equals(Commitment.finalized));
      },
    );

    test(
      'aborts the abort signal passed to strategies when caller aborts',
      () async {
        AbortSignal? capturedNonceAbortSignal;
        AbortSignal? capturedSignatureAbortSignal;
        final callerAbortController = AbortController();

        unawaited(
          waitForDurableNonceTransactionConfirmation(
            abortSignal: callerAbortController.signal,
            commitment: Commitment.finalized,
            getNonceInvalidationPromise:
                ({
                  required AbortSignal abortSignal,
                  required Commitment commitment,
                  required String expectedNonceValue,
                  required String nonceAccountAddress,
                }) {
                  capturedNonceAbortSignal = abortSignal;
                  return Completer<Never>().future;
                },
            getRecentSignatureConfirmationPromise:
                ({
                  required AbortSignal abortSignal,
                  required Commitment commitment,
                  required String signature,
                }) {
                  capturedSignatureAbortSignal = abortSignal;
                  return Completer<void>().future;
                },
            nonceAccountAddress: 'nonce_address',
            nonceValue: 'xyz',
            signature: 'test_signature',
          ).catchError((_) {}),
        );

        await Future<void>.delayed(Duration.zero);

        expect(capturedNonceAbortSignal!.isAborted, isFalse);
        expect(capturedSignatureAbortSignal!.isAborted, isFalse);

        callerAbortController.abort('test');
        await Future<void>.delayed(Duration.zero);

        expect(capturedNonceAbortSignal!.isAborted, isTrue);
        expect(capturedSignatureAbortSignal!.isAborted, isTrue);
      },
    );
  });

  group('waitForRecentTransactionConfirmation', () {
    late Completer<Never> blockHeightExceedenceCompleter;
    late Completer<void> signatureConfirmationCompleter;

    late Future<Never> Function({
      required AbortSignal abortSignal,
      required BigInt lastValidBlockHeight,
      Commitment? commitment,
    })
    getBlockHeightExceedencePromise;
    late Future<void> Function({
      required AbortSignal abortSignal,
      required Commitment commitment,
      required String signature,
    })
    getRecentSignatureConfirmationPromise;

    setUp(() {
      blockHeightExceedenceCompleter = Completer<Never>();
      signatureConfirmationCompleter = Completer<void>();

      getBlockHeightExceedencePromise =
          ({
            required AbortSignal abortSignal,
            required BigInt lastValidBlockHeight,
            Commitment? commitment,
          }) {
            return blockHeightExceedenceCompleter.future;
          };

      getRecentSignatureConfirmationPromise =
          ({
            required AbortSignal abortSignal,
            required Commitment commitment,
            required String signature,
          }) {
            return signatureConfirmationCompleter.future;
          };
    });

    test('throws when the signal is already aborted', () async {
      final abortController = AbortController()..abort();

      await expectLater(
        waitForRecentTransactionConfirmation(
          abortSignal: abortController.signal,
          commitment: Commitment.finalized,
          getBlockHeightExceedencePromise: getBlockHeightExceedencePromise,
          getRecentSignatureConfirmationPromise:
              getRecentSignatureConfirmationPromise,
          lastValidBlockHeight: BigInt.from(123),
          signature: 'test_signature',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('aborted'),
          ),
        ),
      );
    });

    test('resolves when the signature confirmation promise resolves '
        'despite the block height exceedence promise having thrown', () async {
      // Complete the signature confirmation immediately.
      signatureConfirmationCompleter.complete();

      // Schedule the block height error to fire asynchronously so the
      // futures are being listened to before the error occurs.
      Future<void>.delayed(Duration.zero, () {
        blockHeightExceedenceCompleter.completeError(StateError('o no'));
      }).ignore();

      await waitForRecentTransactionConfirmation(
        abortSignal: AbortController().signal,
        commitment: Commitment.finalized,
        getBlockHeightExceedencePromise: getBlockHeightExceedencePromise,
        getRecentSignatureConfirmationPromise:
            getRecentSignatureConfirmationPromise,
        lastValidBlockHeight: BigInt.from(123),
        signature: 'test_signature',
      );
    });

    test('throws when the block height exceedence promise throws', () async {
      blockHeightExceedenceCompleter.completeError(StateError('o no'));

      await expectLater(
        waitForRecentTransactionConfirmation(
          abortSignal: AbortController().signal,
          commitment: Commitment.finalized,
          getBlockHeightExceedencePromise: getBlockHeightExceedencePromise,
          getRecentSignatureConfirmationPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
                required String signature,
              }) {
                return Completer<void>().future;
              },
          lastValidBlockHeight: BigInt.from(123),
          signature: 'test_signature',
        ),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', equals('o no')),
        ),
      );
    });

    test('throws when the signature confirmation promise throws', () async {
      signatureConfirmationCompleter.completeError(StateError('o no'));

      await expectLater(
        waitForRecentTransactionConfirmation(
          abortSignal: AbortController().signal,
          commitment: Commitment.finalized,
          getBlockHeightExceedencePromise:
              ({
                required AbortSignal abortSignal,
                required BigInt lastValidBlockHeight,
                Commitment? commitment,
              }) {
                return Completer<Never>().future;
              },
          getRecentSignatureConfirmationPromise:
              getRecentSignatureConfirmationPromise,
          lastValidBlockHeight: BigInt.from(123),
          signature: 'test_signature',
        ),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', equals('o no')),
        ),
      );
    });

    test(
      'calls getBlockHeightExceedencePromise with the necessary input',
      () async {
        Commitment? capturedCommitment;
        BigInt? capturedLastValidBlockHeight;

        unawaited(
          waitForRecentTransactionConfirmation(
            abortSignal: AbortController().signal,
            commitment: Commitment.finalized,
            getBlockHeightExceedencePromise:
                ({
                  required AbortSignal abortSignal,
                  required BigInt lastValidBlockHeight,
                  Commitment? commitment,
                }) {
                  capturedCommitment = commitment;
                  capturedLastValidBlockHeight = lastValidBlockHeight;
                  return Completer<Never>().future;
                },
            getRecentSignatureConfirmationPromise:
                ({
                  required AbortSignal abortSignal,
                  required Commitment commitment,
                  required String signature,
                }) {
                  return Completer<void>().future;
                },
            lastValidBlockHeight: BigInt.from(123),
            signature: 'test_signature',
          ).catchError((_) {}),
        );

        await Future<void>.delayed(Duration.zero);

        expect(capturedCommitment, equals(Commitment.finalized));
        expect(capturedLastValidBlockHeight, equals(BigInt.from(123)));
      },
    );

    test(
      'calls getRecentSignatureConfirmationPromise with the necessary input',
      () async {
        String? capturedSignature;
        Commitment? capturedCommitment;

        unawaited(
          waitForRecentTransactionConfirmation(
            abortSignal: AbortController().signal,
            commitment: Commitment.finalized,
            getBlockHeightExceedencePromise:
                ({
                  required AbortSignal abortSignal,
                  required BigInt lastValidBlockHeight,
                  Commitment? commitment,
                }) {
                  return Completer<Never>().future;
                },
            getRecentSignatureConfirmationPromise:
                ({
                  required AbortSignal abortSignal,
                  required Commitment commitment,
                  required String signature,
                }) {
                  capturedSignature = signature;
                  capturedCommitment = commitment;
                  return Completer<void>().future;
                },
            lastValidBlockHeight: BigInt.from(123),
            signature: 'test_signature',
          ).catchError((_) {}),
        );

        await Future<void>.delayed(Duration.zero);

        expect(capturedSignature, equals('test_signature'));
        expect(capturedCommitment, equals(Commitment.finalized));
      },
    );

    test(
      'aborts the abort signal passed to strategies when caller aborts',
      () async {
        AbortSignal? capturedBlockHeightAbortSignal;
        AbortSignal? capturedSignatureAbortSignal;
        final callerAbortController = AbortController();

        unawaited(
          waitForRecentTransactionConfirmation(
            abortSignal: callerAbortController.signal,
            commitment: Commitment.finalized,
            getBlockHeightExceedencePromise:
                ({
                  required AbortSignal abortSignal,
                  required BigInt lastValidBlockHeight,
                  Commitment? commitment,
                }) {
                  capturedBlockHeightAbortSignal = abortSignal;
                  return Completer<Never>().future;
                },
            getRecentSignatureConfirmationPromise:
                ({
                  required AbortSignal abortSignal,
                  required Commitment commitment,
                  required String signature,
                }) {
                  capturedSignatureAbortSignal = abortSignal;
                  return Completer<void>().future;
                },
            lastValidBlockHeight: BigInt.from(123),
            signature: 'test_signature',
          ).catchError((_) {}),
        );

        await Future<void>.delayed(Duration.zero);

        expect(capturedBlockHeightAbortSignal!.isAborted, isFalse);
        expect(capturedSignatureAbortSignal!.isAborted, isFalse);

        callerAbortController.abort('test');
        await Future<void>.delayed(Duration.zero);

        expect(capturedBlockHeightAbortSignal!.isAborted, isTrue);
        expect(capturedSignatureAbortSignal!.isAborted, isTrue);
      },
    );
  });

  group('waitForRecentTransactionConfirmationUntilTimeout', () {
    test('throws when the signal is already aborted', () async {
      final abortController = AbortController()..abort();

      await expectLater(
        // Deprecated method under test.
        // ignore: deprecated_member_use_from_same_package
        waitForRecentTransactionConfirmationUntilTimeout(
          abortSignal: abortController.signal,
          commitment: Commitment.finalized,
          getTimeoutPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
              }) {
                return Completer<Never>().future;
              },
          getRecentSignatureConfirmationPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
                required String signature,
              }) {
                return Completer<void>().future;
              },
          signature: 'test_signature',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('aborted'),
          ),
        ),
      );
    });

    test('resolves when the signature confirmation promise resolves '
        'despite the timeout promise having thrown', () async {
      final timeoutCompleter = Completer<Never>();

      // Schedule the timeout error to fire asynchronously so the
      // futures are being listened to before the error occurs.
      Future<void>.delayed(Duration.zero, () {
        timeoutCompleter.completeError(StateError('timeout'));
      }).ignore();

      // Deprecated method under test.
      // ignore: deprecated_member_use_from_same_package
      await waitForRecentTransactionConfirmationUntilTimeout(
        abortSignal: AbortController().signal,
        commitment: Commitment.finalized,
        getTimeoutPromise:
            ({
              required AbortSignal abortSignal,
              required Commitment commitment,
            }) {
              return timeoutCompleter.future;
            },
        getRecentSignatureConfirmationPromise:
            ({
              required AbortSignal abortSignal,
              required Commitment commitment,
              required String signature,
            }) async {},
        signature: 'test_signature',
      );
    });

    test('throws when the timeout promise throws', () async {
      await expectLater(
        // Deprecated method under test.
        // ignore: deprecated_member_use_from_same_package
        waitForRecentTransactionConfirmationUntilTimeout(
          abortSignal: AbortController().signal,
          commitment: Commitment.finalized,
          getTimeoutPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
              }) async {
                throw StateError('o no');
              },
          getRecentSignatureConfirmationPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
                required String signature,
              }) {
                return Completer<void>().future;
              },
          signature: 'test_signature',
        ),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', equals('o no')),
        ),
      );
    });

    test('throws when the signature confirmation promise throws', () async {
      await expectLater(
        // Deprecated method under test.
        // ignore: deprecated_member_use_from_same_package
        waitForRecentTransactionConfirmationUntilTimeout(
          abortSignal: AbortController().signal,
          commitment: Commitment.finalized,
          getTimeoutPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
              }) {
                return Completer<Never>().future;
              },
          getRecentSignatureConfirmationPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
                required String signature,
              }) async {
                throw StateError('o no');
              },
          signature: 'test_signature',
        ),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', equals('o no')),
        ),
      );
    });

    test('calls getTimeoutPromise with the necessary input', () async {
      Commitment? capturedCommitment;

      unawaited(
        // Deprecated method under test.
        // ignore: deprecated_member_use_from_same_package
        waitForRecentTransactionConfirmationUntilTimeout(
          abortSignal: AbortController().signal,
          commitment: Commitment.finalized,
          getTimeoutPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
              }) {
                capturedCommitment = commitment;
                return Completer<Never>().future;
              },
          getRecentSignatureConfirmationPromise:
              ({
                required AbortSignal abortSignal,
                required Commitment commitment,
                required String signature,
              }) {
                return Completer<void>().future;
              },
          signature: 'test_signature',
        ).catchError((_) {}),
      );

      await Future<void>.delayed(Duration.zero);

      expect(capturedCommitment, equals(Commitment.finalized));
    });
  });
}
