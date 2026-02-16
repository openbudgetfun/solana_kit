import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

/// An entry in the channel pool.
class ChannelPoolEntry {
  /// Creates a new [ChannelPoolEntry].
  ChannelPoolEntry({
    required this.channel,
    required this.dispose,
    this.subscriptionCount = 0,
  });

  /// The channel (may be a pending future or resolved channel).
  final Future<RpcSubscriptionsChannel> channel;

  /// Disposes this pool entry by aborting the underlying channel.
  final void Function() dispose;

  /// The number of active subscribers on this channel.
  int subscriptionCount;
}

/// A pool of channel entries.
class ChannelPool {
  /// The entries in the pool.
  final List<ChannelPoolEntry> entries = [];

  /// The index of the channel with the most available capacity, or `-1` if
  /// no channel has capacity (meaning a new one must be created).
  int freeChannelIndex = -1;
}

/// Creates a new empty [ChannelPool].
ChannelPool createChannelPool() {
  return ChannelPool();
}
