import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Information about the current epoch.
class EpochInfo {
  /// Creates an [EpochInfo].
  const EpochInfo({required this.absoluteSlot, required this.blockHeight});

  /// The current slot.
  final BigInt absoluteSlot;

  /// The current block height.
  final BigInt blockHeight;
}

/// A slot notification from the RPC subscription.
class SlotNotification {
  /// Creates a [SlotNotification].
  const SlotNotification({required this.slot});

  /// The slot number.
  final BigInt slot;
}

/// Configuration for the block height exceedence promise factory.
class BlockHeightExceedenceConfig {
  /// Creates a [BlockHeightExceedenceConfig].
  const BlockHeightExceedenceConfig({
    required this.getEpochInfo,
    required this.onSlotNotification,
  });

  /// Function to get epoch info from the RPC.
  final Future<EpochInfo> Function({
    required AbortSignal abortSignal,
    Commitment? commitment,
  })
  getEpochInfo;

  /// Function to subscribe to slot notifications.
  ///
  /// Should call the `onNotification` callback for each slot notification,
  /// and return a future that completes when the subscription ends.
  final Future<void> Function({
    required AbortSignal abortSignal,
    required void Function(SlotNotification notification) onNotification,
  })
  onSlotNotification;
}

/// Creates a factory function that returns a promise that rejects when the
/// network block height exceeds the transaction's last valid block height.
///
/// When a transaction's lifetime is tied to a blockhash, that transaction can
/// be landed on the network until that blockhash expires. All blockhashes have
/// a block height after which they are considered to have expired.
///
/// Throws [SolanaError] with [SolanaErrorCode.blockHeightExceeded] when the
/// block height has been exceeded.
Future<Never> Function({
  required AbortSignal abortSignal,
  required BigInt lastValidBlockHeight,
  Commitment? commitment,
})
createBlockHeightExceedencePromiseFactory(BlockHeightExceedenceConfig config) {
  return ({
    required AbortSignal abortSignal,
    required BigInt lastValidBlockHeight,
    Commitment? commitment,
  }) async {
    if (abortSignal.isAborted) {
      throw StateError('The operation was aborted: ${abortSignal.reason}');
    }

    final abortController = AbortController();

    abortSignal.future.then((_) {
      abortController.abort(abortSignal.reason);
    }).ignore();

    Future<
      ({BigInt blockHeight, BigInt differenceBetweenSlotHeightAndBlockHeight})
    >
    getBlockHeightAndDifference() async {
      final epochInfo = await config.getEpochInfo(
        abortSignal: abortController.signal,
        commitment: commitment,
      );
      return (
        blockHeight: epochInfo.blockHeight,
        differenceBetweenSlotHeightAndBlockHeight:
            epochInfo.absoluteSlot - epochInfo.blockHeight,
      );
    }

    try {
      // Fetch initial block height and set up slot subscription in parallel.
      final initialInfoCompleter =
          Completer<
            ({
              BigInt blockHeight,
              BigInt differenceBetweenSlotHeightAndBlockHeight,
            })
          >();
      final slotNotifications = <SlotNotification>[];
      var slotNotificationCallback = (SlotNotification _) {};

      unawaited(
        config
            .onSlotNotification(
              abortSignal: abortController.signal,
              onNotification: (notification) {
                slotNotificationCallback(notification);
              },
            )
            .catchError((Object error) {
              if (!initialInfoCompleter.isCompleted) {
                initialInfoCompleter.completeError(error);
              }
            }),
      );

      unawaited(
        getBlockHeightAndDifference()
            .then((info) {
              if (!initialInfoCompleter.isCompleted) {
                initialInfoCompleter.complete(info);
              }
            })
            .catchError((Object error) {
              if (!initialInfoCompleter.isCompleted) {
                initialInfoCompleter.completeError(error);
              }
            }),
      );

      final initialInfo = await initialInfoCompleter.future;

      if (abortSignal.isAborted) {
        throw StateError('The operation was aborted: ${abortSignal.reason}');
      }

      var currentBlockHeight = initialInfo.blockHeight;

      if (currentBlockHeight <= lastValidBlockHeight) {
        var lastKnownDifference =
            initialInfo.differenceBetweenSlotHeightAndBlockHeight;

        // Process slot notifications.
        final exceedenceCompleter = Completer<Never>();

        slotNotificationCallback = (SlotNotification notification) {
          if (exceedenceCompleter.isCompleted) return;

          final slot = notification.slot;
          if (slot - lastKnownDifference > lastValidBlockHeight) {
            // Before making a final decision, recheck the actual block height.
            unawaited(
              getBlockHeightAndDifference()
                  .then((rechecked) {
                    if (exceedenceCompleter.isCompleted) return;
                    currentBlockHeight = rechecked.blockHeight;
                    if (currentBlockHeight > lastValidBlockHeight) {
                      exceedenceCompleter.completeError(
                        SolanaError(SolanaErrorCode.blockHeightExceeded, {
                          'currentBlockHeight': currentBlockHeight,
                          'lastValidBlockHeight': lastValidBlockHeight,
                        }),
                      );
                    } else {
                      // Recalibrate the difference and keep waiting.
                      lastKnownDifference =
                          rechecked.differenceBetweenSlotHeightAndBlockHeight;
                    }
                  })
                  .catchError((Object error) {
                    if (!exceedenceCompleter.isCompleted) {
                      exceedenceCompleter.completeError(error);
                    }
                  }),
            );
          }
        };

        // Also process any notifications that arrived before we set up
        // the callback.
        for (final notification in slotNotifications) {
          slotNotificationCallback(notification);
        }

        return await exceedenceCompleter.future;
      }

      if (abortSignal.isAborted) {
        throw StateError('The operation was aborted: ${abortSignal.reason}');
      }

      throw SolanaError(SolanaErrorCode.blockHeightExceeded, {
        'currentBlockHeight': currentBlockHeight,
        'lastValidBlockHeight': lastValidBlockHeight,
      });
    } finally {
      abortController.abort();
    }
  };
}
