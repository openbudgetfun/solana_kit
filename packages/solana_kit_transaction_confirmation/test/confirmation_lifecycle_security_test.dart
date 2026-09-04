import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:test/test.dart';

void main() {
  for (final kind in _StrategyKind.values) {
    group('$kind subscription lifecycle', () {
      test(
        'ignores late cancellation after synchronous subscription failure',
        () async {
          final harness = _StrategyHarness(kind, subscribeThrows: true);
          final source = CancellationTokenSource();
          await expectLater(
            harness.run(source.token),
            throwsA(same(harness.failure)),
          );
          source.cancel('late cancellation');
          await _flush();
        },
      );

      test(
        'absorbs subscription failure after synchronous lookup failure',
        () async {
          final harness = _StrategyHarness(kind, lookupThrows: true);
          final source = CancellationTokenSource();
          await expectLater(
            harness.run(source.token),
            throwsA(same(harness.failure)),
          );
          harness.subscription.completeError(
            StateError('late subscription failure'),
          );
          source.cancel('late cancellation');
          await _flush();
        },
      );

      test(
        'rejects a previously cancelled operation before starting IO',
        () async {
          final harness = _StrategyHarness(kind);
          final source = CancellationTokenSource()..cancel('cancelled');
          await expectLater(
            harness.run(source.token).timeout(_deadline),
            throwsA(isA<StateError>()),
          );
          expect(harness.requestCount, 0);
        },
      );

      test('settles cancellation after the initial lookup completes', () async {
        final harness = _StrategyHarness(kind);
        final source = CancellationTokenSource();
        final result = harness.run(source.token);
        final assertion = expectLater(
          result.timeout(_deadline),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('cancelled'),
            ),
          ),
        );
        await _flush();
        source.cancel('cancelled');
        await assertion;
        expect(harness.innerToken!.isCancelled, isTrue);
      });

      test('propagates a late subscription error instead of hanging', () async {
        final harness = _StrategyHarness(kind);
        final result = harness.run(CancellationTokenSource().token);
        final error = StateError('connection lost');
        final assertion = expectLater(
          result.timeout(_deadline),
          throwsA(same(error)),
        );
        await _flush();
        harness.subscription.completeError(error);
        await assertion;
        expect(harness.innerToken!.isCancelled, isTrue);
      });

      test(
        'rejects a subscription that ends without a terminal notification',
        () async {
          final harness = _StrategyHarness(kind);
          final result = harness.run(CancellationTokenSource().token);
          final assertion = expectLater(
            result.timeout(_deadline),
            throwsA(isA<StateError>()),
          );
          await _flush();
          harness.subscription.complete();
          await assertion;
        },
      );
    });
  }

  test(
    'ignores late cancellation after a strategy factory throws synchronously',
    () async {
      final source = CancellationTokenSource();
      final error = StateError('synchronous strategy failure');
      await expectLater(
        raceStrategies(
          'signature',
          BaseTransactionConfirmationStrategyConfig(
            abortSignal: source.token,
            commitment: Commitment.confirmed,
            getRecentSignatureConfirmationPromise:
                ({
                  required abortSignal,
                  required commitment,
                  required signature,
                }) => Completer<void>().future,
          ),
          ({required abortSignal}) => throw error,
        ),
        throwsA(same(error)),
      );
      source.cancel('late cancellation');
      await _flush();
    },
  );

  test(
    'blockheight preserves a slot notification received during the lookup',
    () async {
      final initial = Completer<EpochInfo>();
      var requests = 0;
      final factory = createBlockHeightExceedencePromiseFactory(
        BlockHeightExceedenceConfig(
          getEpochInfo: ({required abortSignal, commitment}) {
            requests++;
            return requests == 1
                ? initial.future
                : Future.value(
                    EpochInfo(
                      absoluteSlot: BigInt.from(102),
                      blockHeight: BigInt.from(102),
                    ),
                  );
          },
          onSlotNotification:
              ({required abortSignal, required onNotification}) {
                onNotification(SlotNotification(slot: BigInt.from(102)));
                return Completer<void>().future;
              },
        ),
      );
      final result = factory(
        abortSignal: CancellationTokenSource().token,
        lastValidBlockHeight: BigInt.from(100),
      );
      final assertion = expectLater(
        result.timeout(_deadline),
        throwsA(
          isA<SolanaError>().having(
            (error) => error.code,
            'code',
            SolanaErrorCode.blockHeightExceeded,
          ),
        ),
      );
      initial.complete(
        EpochInfo(
          absoluteSlot: BigInt.from(100),
          blockHeight: BigInt.from(100),
        ),
      );
      await assertion;
      expect(requests, 2);
    },
  );

  test(
    'cancelling a strategy race settles even when its strategies are inert',
    () async {
      final source = CancellationTokenSource();
      final result = raceStrategies(
        'signature',
        BaseTransactionConfirmationStrategyConfig(
          abortSignal: source.token,
          commitment: Commitment.confirmed,
          getRecentSignatureConfirmationPromise:
              ({
                required abortSignal,
                required commitment,
                required signature,
              }) => Completer<void>().future,
        ),
        ({required abortSignal}) => [Completer<void>().future],
      );
      final assertion = expectLater(
        result.timeout(_deadline),
        throwsA(isA<StateError>()),
      );
      source.cancel('cancelled');
      await assertion;
    },
  );
}

const _deadline = Duration(seconds: 1);

Future<void> _flush() => Future<void>.delayed(Duration.zero);

enum _StrategyKind { signature, nonce, blockheight }

class _StrategyHarness {
  _StrategyHarness(
    this.kind, {
    this.lookupThrows = false,
    this.subscribeThrows = false,
  });

  final bool lookupThrows;
  final bool subscribeThrows;
  final failure = StateError('synchronous failure');

  final _StrategyKind kind;
  final subscription = Completer<void>();
  CancellationToken? innerToken;
  int requestCount = 0;

  Future<void> run(CancellationToken token) {
    switch (kind) {
      case _StrategyKind.signature:
        return createRecentSignatureConfirmationPromiseFactory(
          RecentSignatureConfirmationConfig(
            getSignatureStatuses: (signatures, {required abortSignal}) {
              requestCount++;
              if (lookupThrows) throw failure;
              return Future.value([null]);
            },
            onSignatureNotification:
                (
                  signature, {
                  required abortSignal,
                  required commitment,
                  required onNotification,
                }) {
                  innerToken = abortSignal;
                  if (subscribeThrows) throw failure;
                  return subscription.future;
                },
          ),
        )(
          abortSignal: token,
          commitment: Commitment.confirmed,
          signature: 'sig',
        );
      case _StrategyKind.nonce:
        return createNonceInvalidationPromiseFactory(
          NonceInvalidationConfig(
            getNonceAccount:
                (address, {required abortSignal, required commitment}) {
                  requestCount++;
                  if (lookupThrows) throw failure;
                  return Future.value(
                    const NonceAccountInfo(nonceValue: 'nonce'),
                  );
                },
            onAccountNotification:
                (
                  address, {
                  required abortSignal,
                  required commitment,
                  required onNotification,
                }) {
                  innerToken = abortSignal;
                  if (subscribeThrows) throw failure;
                  return subscription.future;
                },
          ),
        )(
          abortSignal: token,
          commitment: Commitment.confirmed,
          expectedNonceValue: 'nonce',
          nonceAccountAddress: 'address',
        );
      case _StrategyKind.blockheight:
        return createBlockHeightExceedencePromiseFactory(
          BlockHeightExceedenceConfig(
            getEpochInfo: ({required abortSignal, commitment}) {
              requestCount++;
              if (lookupThrows) throw failure;
              return Future.value(
                EpochInfo(
                  absoluteSlot: BigInt.one,
                  blockHeight: BigInt.one,
                ),
              );
            },
            onSlotNotification:
                ({required abortSignal, required onNotification}) {
                  innerToken = abortSignal;
                  if (subscribeThrows) throw failure;
                  return subscription.future;
                },
          ),
        )(abortSignal: token, lastValidBlockHeight: BigInt.from(100));
    }
  }
}
