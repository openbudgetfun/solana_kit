import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

/// A value just above Dart's safe integer threshold for testing BigInt.
final _maxSafeIntegerPlusOne =
    BigInt.from(9007199254740991) + BigInt.one; // 2^53

void main() {
  group('getRpcSubscriptionsChannelWithBigIntJsonSerialization', () {
    late _MockChannel mockChannel;
    late WritableDataPublisher dataPublisher;

    setUp(() {
      dataPublisher = createDataPublisher();
      mockChannel = _MockChannel(dataPublisher: dataPublisher);
    });

    test(
      'forwards JSON-serialized large integers to the underlying channel',
      () {
        getRpcSubscriptionsChannelWithBigIntJsonSerialization(
          mockChannel,
        ).send({'value': _maxSafeIntegerPlusOne});

        expect(
          mockChannel.lastSentMessage,
          equals('{"value":$_maxSafeIntegerPlusOne}'),
        );
      },
    );

    test('deserializes large integers received from the underlying channel as '
        'JSON', () {
      final channel = getRpcSubscriptionsChannelWithBigIntJsonSerialization(
        mockChannel,
      );

      Object? receivedMessage;
      channel.on('message', (data) {
        receivedMessage = data;
      });

      dataPublisher.publish('message', '{"value":$_maxSafeIntegerPlusOne}');

      expect(receivedMessage, isA<Map<String, Object?>>());
      final map = receivedMessage! as Map<String, Object?>;
      expect(map['value'], equals(_maxSafeIntegerPlusOne));
    });
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
