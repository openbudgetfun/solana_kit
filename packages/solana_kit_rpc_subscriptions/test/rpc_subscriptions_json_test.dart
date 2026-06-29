import 'dart:async';
import 'dart:convert';

import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('getRpcSubscriptionsChannelWithJsonSerialization', () {
    late _MockChannel mockChannel;

    setUp(() {
      mockChannel = _MockChannel();
    });

    test(
      'forwards JSON-serialized messages to the underlying channel',
      () async {
        await getRpcSubscriptionsChannelWithJsonSerialization(
          mockChannel,
        ).send('hello');

        expect(mockChannel.lastSentMessage, equals(jsonEncode('hello')));
      },
    );

    test(
      'deserializes messages received from the underlying channel as JSON',
      () async {
        final channelWithJsonSerialization =
            getRpcSubscriptionsChannelWithJsonSerialization(mockChannel);

        Object? receivedMessage;
        final subscription = channelWithJsonSerialization.streams.notifications
            .listen((data) {
              receivedMessage = data;
            });

        mockChannel.publishMessage(jsonEncode('hello'));

        expect(receivedMessage, equals('hello'));
        await subscription.cancel();
      },
    );
  });
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

  void publishError(Object? error) {
    if (!_errorsController.isClosed) _errorsController.add(error);
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
