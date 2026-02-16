import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_channel_pool_internal.dart';
import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_transport.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

/// Wraps a channel creator to pool channels.
///
/// The returned channel creator has the following behavior:
///
/// 1. When called, returns an [RpcSubscriptionsChannel]. Adds that channel to
///    a pool.
/// 2. When called again, creates and returns new channels up to the number
///    specified by [minChannels].
/// 3. When [minChannels] channels have been created, subsequent calls vend
///    whichever existing channel from the pool has the fewest subscribers, or
///    the next one in rotation in the event of a tie.
/// 4. Once all channels carry the number of subscribers specified by
///    [maxSubscriptionsPerChannel], new channels in excess of [minChannels]
///    will be created, returned, and added to the pool.
/// 5. A channel will be destroyed once all of its subscribers' abort signals
///    fire.
RpcSubscriptionsChannelCreator getChannelPoolingChannelCreator(
  RpcSubscriptionsChannelCreator createChannel, {
  required int maxSubscriptionsPerChannel,
  required int minChannels,
}) {
  final pool = createChannelPool();

  /// Advances the free channel index to the pool entry with the most
  /// capacity. Sets the index to `-1` if all channels are full.
  void recomputeFreeChannelIndex() {
    if (pool.entries.length < minChannels) {
      // Don't set the free channel index until the pool fills up; we want
      // to keep creating channels before we start rotating among them.
      pool.freeChannelIndex = -1;
      return;
    }

    int? mostFreePoolIndex;
    int? mostFreeSubscriptionCount;

    for (var ii = 0; ii < pool.entries.length; ii++) {
      final nextPoolIndex =
          (pool.freeChannelIndex + ii + 2) % pool.entries.length;
      final nextPoolEntry = pool.entries[nextPoolIndex];

      if (nextPoolEntry.subscriptionCount < maxSubscriptionsPerChannel &&
          (mostFreeSubscriptionCount == null ||
              mostFreeSubscriptionCount >= nextPoolEntry.subscriptionCount)) {
        mostFreePoolIndex = nextPoolIndex;
        mostFreeSubscriptionCount = nextPoolEntry.subscriptionCount;
      }
    }

    pool.freeChannelIndex = mostFreePoolIndex ?? -1;
  }

  return ({required AbortSignal abortSignal}) {
    late ChannelPoolEntry poolEntry;

    void destroyPoolEntry() {
      final index = pool.entries.indexOf(poolEntry);
      if (index != -1) {
        pool.entries.removeAt(index);
      }
      poolEntry.dispose();
      recomputeFreeChannelIndex();
    }

    if (pool.freeChannelIndex == -1) {
      final abortController = AbortController();
      final newChannelFuture = createChannel(
        abortSignal: abortController.signal,
      );

      newChannelFuture
          .then((newChannel) {
            newChannel.on('error', (_) {
              destroyPoolEntry();
            });
          })
          .onError<Object>((_, __) {
            destroyPoolEntry();
          });

      poolEntry = ChannelPoolEntry(
        channel: newChannelFuture,
        dispose: abortController.abort,
      );
      pool.entries.add(poolEntry);
    } else {
      poolEntry = pool.entries[pool.freeChannelIndex];
    }

    // Increment subscription count unconditionally. See the note in the TS
    // source about server-side subscription coalescing (solana-labs PR 18943)
    // which means we can't know for certain if a subscription will be
    // treated as a new slot or not.
    poolEntry.subscriptionCount++;

    abortSignal.future.then((_) {
      poolEntry.subscriptionCount--;
      if (poolEntry.subscriptionCount == 0) {
        destroyPoolEntry();
      } else if (pool.freeChannelIndex != -1) {
        // Back the free channel index up one position, and recompute it.
        pool.freeChannelIndex--;
        recomputeFreeChannelIndex();
      }
    }).ignore();

    recomputeFreeChannelIndex();
    return poolEntry.channel;
  };
}
