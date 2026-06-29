import 'dart:async';

import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

/// A value just above Dart's safe integer threshold for testing BigInt.
final BigInt _maxSafeIntegerPlusOne =
    BigInt.from(9007199254740991) + BigInt.one; // 2^53

void main() {
  group('getRpcSubscriptionsChannelWithBigIntJsonSerialization', () {
    late _MockChannel mockChannel;

    setUp(() {
      mockChannel = _MockChannel();
    });

    test(
      'forwards JSON-serialized large integers to the underlying channel',
      () async {
        await getRpcSubscriptionsChannelWithBigIntJsonSerialization(
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
      final subscription = channel.streams.notifications.listen((data) {
        receivedMessage = data;
      });

      mockChannel.publishMessage('{"value":$_maxSafeIntegerPlusOne}');

      expect(receivedMessage, isA<Map<String, Object?>>());
      final map = receivedMessage! as Map<String, Object?>;
      expect(map['value'], equals(_maxSafeIntegerPlusOne));
      subscription.cancel();
    });
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
