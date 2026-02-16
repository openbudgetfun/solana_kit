import 'dart:convert';

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

/// Wraps an [RpcSubscriptionsChannel] to serialize outbound messages as JSON
/// strings and deserialize inbound `'message'` events from JSON strings.
///
/// Uses standard `jsonEncode`/`jsonDecode` for serialization. For BigInt-safe
/// serialization, use
/// `getRpcSubscriptionsChannelWithBigIntJsonSerialization` instead.
RpcSubscriptionsChannel getRpcSubscriptionsChannelWithJsonSerialization(
  RpcSubscriptionsChannel channel,
) {
  return _JsonSerializedChannel(channel: channel);
}

class _JsonSerializedChannel implements RpcSubscriptionsChannel {
  _JsonSerializedChannel({required this.channel});

  final RpcSubscriptionsChannel channel;

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    if (channelName != 'message') {
      return channel.on(channelName, subscriber);
    }
    return channel.on('message', (data) {
      subscriber(jsonDecode(data! as String));
    });
  }

  @override
  Future<void> send(Object message) {
    return channel.send(jsonEncode(message));
  }
}
