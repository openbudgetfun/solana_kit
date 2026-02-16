import 'dart:convert';

import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('getRpcSubscriptionsChannelWithJsonSerialization', () {
    late _MockChannel mockChannel;
    late WritableDataPublisher dataPublisher;

    setUp(() {
      dataPublisher = createDataPublisher();
      mockChannel = _MockChannel(dataPublisher: dataPublisher);
    });

    test('forwards JSON-serialized messages to the underlying channel', () {
      getRpcSubscriptionsChannelWithJsonSerialization(
        mockChannel,
      ).send('hello');

      expect(mockChannel.lastSentMessage, equals(jsonEncode('hello')));
    });

    test(
      'deserializes messages received from the underlying channel as JSON',
      () {
        final channelWithJsonSerialization =
            getRpcSubscriptionsChannelWithJsonSerialization(mockChannel);

        Object? receivedMessage;
        channelWithJsonSerialization.on('message', (data) {
          receivedMessage = data;
        });

        dataPublisher.publish('message', jsonEncode('hello'));

        expect(receivedMessage, equals('hello'));
      },
    );
  });
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
