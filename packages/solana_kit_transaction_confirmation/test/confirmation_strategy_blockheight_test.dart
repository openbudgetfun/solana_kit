import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:test/test.dart';

void main() {
  group('createBlockHeightExceedencePromiseFactory', () {
    late List<Completer<EpochInfo>> epochInfoCompleters;
    late void Function(SlotNotification notification)? slotCallback;
    late Future<Never> Function({
      required AbortSignal abortSignal,
      required BigInt lastValidBlockHeight,
      Commitment? commitment,
    })
    getBlockHeightExceedencePromise;

    setUp(() {
      epochInfoCompleters = [];
      slotCallback = null;

      getBlockHeightExceedencePromise =
          createBlockHeightExceedencePromiseFactory(
            BlockHeightExceedenceConfig(
              getEpochInfo:
                  ({required AbortSignal abortSignal, Commitment? commitment}) {
                    final completer = Completer<EpochInfo>();
                    epochInfoCompleters.add(completer);
                    return completer.future;
                  },
              onSlotNotification:
                  ({
                    required AbortSignal abortSignal,
                    required void Function(SlotNotification notification)
                    onNotification,
                  }) async {
                    slotCallback = onNotification;
                    // Keep subscription open.
                    await Completer<void>().future;
                  },
            ),
          );
    });

    test(
      'throws when the block height has already been exceeded when called',
      () async {
        epochInfoCompleters.clear();
        final future = getBlockHeightExceedencePromise(
          abortSignal: AbortController().signal,
          lastValidBlockHeight: BigInt.from(100),
        );

        await Future<void>.delayed(Duration.zero);
        epochInfoCompleters[0].complete(
          EpochInfo(
            absoluteSlot: BigInt.from(101),
            blockHeight: BigInt.from(101),
          ),
        );

        await expectLater(
          future,
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              equals(SolanaErrorCode.blockHeightExceeded),
            ),
          ),
        );
      },
    );

    test('continues to pend when the block height in the initial fetch '
        'is equal to the last valid block height', () async {
      final future = getBlockHeightExceedencePromise(
        abortSignal: AbortController().signal,
        lastValidBlockHeight: BigInt.from(100),
      );

      await Future<void>.delayed(Duration.zero);
      epochInfoCompleters[0].complete(
        EpochInfo(
          absoluteSlot: BigInt.from(100),
          blockHeight: BigInt.from(100),
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final result = await Future.any([
        future.then<String>((_) => 'resolved').catchError((_) => 'rejected'),
        Future<String>.delayed(
          const Duration(milliseconds: 50),
          () => 'pending',
        ),
      ]);
      expect(result, equals('pending'));
    });

    test('throws when the slot at which the block height is expected to '
        'be exceeded is reached', () async {
      final future = getBlockHeightExceedencePromise(
        abortSignal: AbortController().signal,
        lastValidBlockHeight: BigInt.from(100),
      );

      await Future<void>.delayed(Duration.zero);

      // Initial: slot 198, height 98 (difference of 100).
      epochInfoCompleters[0].complete(
        EpochInfo(absoluteSlot: BigInt.from(198), blockHeight: BigInt.from(98)),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Emit slot notifications.
      slotCallback!(SlotNotification(slot: BigInt.from(199)));
      await Future<void>.delayed(Duration.zero);
      slotCallback!(SlotNotification(slot: BigInt.from(200)));
      await Future<void>.delayed(Duration.zero);
      // At slot 201, 201 - 100 = 101 > 100 (last valid).
      slotCallback!(SlotNotification(slot: BigInt.from(201)));

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Recheck confirms exceedence.
      epochInfoCompleters[1].complete(
        EpochInfo(
          absoluteSlot: BigInt.from(201),
          blockHeight: BigInt.from(101),
        ),
      );

      await expectLater(
        future,
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.blockHeightExceeded),
          ),
        ),
      );
    });

    test('continues to pend when the recheck shows block height has not '
        'actually exceeded (difference grew)', () async {
      final future = getBlockHeightExceedencePromise(
        abortSignal: AbortController().signal,
        lastValidBlockHeight: BigInt.from(100),
      );

      await Future<void>.delayed(Duration.zero);

      // Initial: slot 198, height 98 (difference of 100).
      epochInfoCompleters[0].complete(
        EpochInfo(absoluteSlot: BigInt.from(198), blockHeight: BigInt.from(98)),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      slotCallback!(SlotNotification(slot: BigInt.from(199)));
      await Future<void>.delayed(Duration.zero);
      slotCallback!(SlotNotification(slot: BigInt.from(200)));
      await Future<void>.delayed(Duration.zero);
      slotCallback!(SlotNotification(slot: BigInt.from(201)));

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Recheck shows the difference grew (some blocks skipped).
      epochInfoCompleters[1].complete(
        EpochInfo(
          absoluteSlot: BigInt.from(201),
          blockHeight: BigInt.from(100),
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final result = await Future.any([
        future.then<String>((_) => 'resolved').catchError((_) => 'rejected'),
        Future<String>.delayed(
          const Duration(milliseconds: 50),
          () => 'pending',
        ),
      ]);
      expect(result, equals('pending'));
    });

    test('throws if started aborted', () async {
      final abortController = AbortController()..abort();

      await expectLater(
        getBlockHeightExceedencePromise(
          abortSignal: abortController.signal,
          lastValidBlockHeight: BigInt.from(100),
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

    test('throws errors thrown from the epoch info fetcher', () async {
      final future = getBlockHeightExceedencePromise(
        abortSignal: AbortController().signal,
        lastValidBlockHeight: BigInt.from(100),
      );

      await Future<void>.delayed(Duration.zero);
      epochInfoCompleters[0].completeError(StateError('o no'));

      await expectLater(
        future,
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', equals('o no')),
        ),
      );
    });

    test('throws errors thrown from the slot subscription', () async {
      final fn = createBlockHeightExceedencePromiseFactory(
        BlockHeightExceedenceConfig(
          getEpochInfo:
              ({
                required AbortSignal abortSignal,
                Commitment? commitment,
              }) async {
                return EpochInfo(
                  absoluteSlot: BigInt.from(100),
                  blockHeight: BigInt.from(100),
                );
              },
          onSlotNotification:
              ({
                required AbortSignal abortSignal,
                required void Function(SlotNotification notification)
                onNotification,
              }) async {
                throw StateError('o no');
              },
        ),
      );

      await expectLater(
        fn(
          abortSignal: AbortController().signal,
          lastValidBlockHeight: BigInt.from(100),
        ),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', equals('o no')),
        ),
      );
    });

    test('passes commitment to the epoch info getter', () async {
      Commitment? capturedCommitment;

      final fn = createBlockHeightExceedencePromiseFactory(
        BlockHeightExceedenceConfig(
          getEpochInfo:
              ({
                required AbortSignal abortSignal,
                Commitment? commitment,
              }) async {
                capturedCommitment = commitment;
                return EpochInfo(
                  absoluteSlot: BigInt.from(101),
                  blockHeight: BigInt.from(101),
                );
              },
          onSlotNotification:
              ({
                required AbortSignal abortSignal,
                required void Function(SlotNotification notification)
                onNotification,
              }) async {
                await Completer<void>().future;
              },
        ),
      );

      try {
        await fn(
          abortSignal: AbortController().signal,
          commitment: Commitment.confirmed,
          lastValidBlockHeight: BigInt.from(100),
        );
      } on SolanaError catch (_) {
        // Expected - block height exceeded.
      }

      expect(capturedCommitment, equals(Commitment.confirmed));
    });
  });
}
