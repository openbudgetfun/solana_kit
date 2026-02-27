// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

Future<void> main() async {
  final publisher = createDataPublisher();
  final baseChannel = _MockChannel(dataPublisher: publisher);
  final jsonChannel = getRpcSubscriptionsChannelWithJsonSerialization(baseChannel);

  Object? received;
  jsonChannel.on('message', (data) {
    received = data;
  });

  await jsonChannel.send('hello');
  publisher.publish('message', jsonEncode('world'));

  print('Outbound message: ${baseChannel.lastSentMessage}');
  print('Inbound message: $received');
}

class _MockChannel implements RpcSubscriptionsChannel {
  _MockChannel({required this.dataPublisher});

  final WritableDataPublisher dataPublisher;
  Object? lastSentMessage;

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    return dataPublisher.on(channelName, subscriber);
  }

  @override
  Future<void> send(Object message) async {
    lastSentMessage = message;
  }
}
