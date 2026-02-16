import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

/// Wraps an [RpcSubscriptionsChannel] to serialize outbound messages using
/// BigInt-safe JSON serialization and deserialize inbound `'message'` events
/// using BigInt-safe JSON parsing.
///
/// This is similar to `getRpcSubscriptionsChannelWithJsonSerialization` but
/// parses any integer value as a [BigInt] to safely handle numbers that exceed
/// Dart's `int` precision.
///
/// This is the recommended serialization for Solana RPC subscriptions since
/// Solana RPC servers accept and return integers larger than JavaScript's
/// `Number.MAX_SAFE_INTEGER`.
RpcSubscriptionsChannel getRpcSubscriptionsChannelWithBigIntJsonSerialization(
  RpcSubscriptionsChannel channel,
) {
  return _BigIntJsonSerializedChannel(channel: channel);
}

class _BigIntJsonSerializedChannel implements RpcSubscriptionsChannel {
  _BigIntJsonSerializedChannel({required this.channel});

  final RpcSubscriptionsChannel channel;

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    if (channelName != 'message') {
      return channel.on(channelName, subscriber);
    }
    return channel.on('message', (data) {
      subscriber(parseJsonWithBigInts(data! as String));
    });
  }

  @override
  Future<void> send(Object message) {
    return channel.send(stringifyJsonWithBigInts(message));
  }
}
