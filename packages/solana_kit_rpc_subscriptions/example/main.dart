// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

Future<void> main() async {
  final baseChannel = _MockChannel();
  final jsonChannel = getRpcSubscriptionsChannelWithJsonSerialization(
    baseChannel,
  );

  Object? received;
  final subscription = jsonChannel.streams.notifications.listen((data) {
    received = data;
  });

  await jsonChannel.send('hello');
  baseChannel.publishMessage(jsonEncode('world'));

  print('Outbound message: ${baseChannel.lastSentMessage}');
  print('Inbound message: $received');

  await subscription.cancel();
}

class _MockChannel implements RpcSubscriptionsChannel {
  _MockChannel()
    : _messagesController = StreamController<Object?>.broadcast(sync: true),
      _errorsController = StreamController<Object?>.broadcast(sync: true);

  final StreamController<Object?> _messagesController;
  final StreamController<Object?> _errorsController;
  Object? lastSentMessage;

  void publishMessage(Object? data) {
    if (!_messagesController.isClosed) _messagesController.add(data);
  }

  @override
  NotificationStreams get streams => NotificationStreams(
    notifications: _messagesController.stream,
    errors: _errorsController.stream,
  );

  @override
  Future<void> send(Object message) async {
    lastSentMessage = message;
  }
}
