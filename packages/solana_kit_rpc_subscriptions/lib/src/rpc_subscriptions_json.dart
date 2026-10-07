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

  // Memoized so that every subscription sharing this channel listens to one
  // mapped stream instead of each creating its own; otherwise each inbound
  // message would be JSON-parsed once per active subscription.
  late final NotificationStreams _streams = NotificationStreams(
    notifications: channel.streams.notifications.map(
      (data) => jsonDecode(data! as String),
    ),
    errors: channel.streams.errors,
  );

  @override
  NotificationStreams get streams => _streams;

  @override
  Future<void> send(Object message) {
    return channel.send(jsonEncode(message));
  }
}
