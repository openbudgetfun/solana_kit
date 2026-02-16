import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('demultiplexDataPublisher', () {
    late WritableDataPublisher mockPublisher;
    late int onCallCount;
    late List<UnsubscribeFn> mockUnsubscribes;

    setUp(() {
      mockPublisher = createDataPublisher();
      onCallCount = 0;
      mockUnsubscribes = [];
    });

    /// Wraps [mockPublisher] in a tracking [DataPublisher] that counts calls
    /// to [DataPublisher.on] and records the returned unsubscribe functions.
    DataPublisher trackingPublisher() {
      return _TrackingDataPublisher(
        mockPublisher,
        onCall: (unsub) {
          onCallCount++;
          mockUnsubscribes.add(unsub);
        },
      );
    }

    test('does not listen to the publisher when there are no subscribers', () {
      demultiplexDataPublisher<Object?>(
        sourcePublisher: trackingPublisher(),
        sourceChannelName: 'channelName',
        messageTransformer: (_) => null,
      );
      expect(onCallCount, 0);
    });

    test('starts to listen to the publisher when a subscriber appears', () {
      demultiplexDataPublisher<Object?>(
        sourcePublisher: trackingPublisher(),
        sourceChannelName: 'channelName',
        messageTransformer: (_) => null,
      ).on('someChannelName', (_) {});
      expect(onCallCount, 1);
    });

    test(
      'only listens to the publisher once despite multiple subscriptions',
      () {
        demultiplexDataPublisher<Object?>(
            sourcePublisher: trackingPublisher(),
            sourceChannelName: 'channelName',
            messageTransformer: (_) => null,
          )
          ..on('someChannelName', (_) {})
          ..on('someOtherChannelName', (_) {});
        expect(onCallCount, 1);
      },
    );

    test(
      'unsubscribes from the publisher once the last subscriber unsubscribes',
      () {
        var sourceUnsubCalled = false;
        final source = _CallbackDataPublisher(
          onSubscribe: (channelName, subscriber) {
            return () {
              sourceUnsubCalled = true;
            };
          },
        );

        final demuxed = demultiplexDataPublisher<Object?>(
          sourcePublisher: source,
          sourceChannelName: 'channelName',
          messageTransformer: (_) => null,
        );

        final unsubscribe = demuxed.on('someChannelName', (_) {});
        unsubscribe();
        expect(sourceUnsubCalled, isTrue);
      },
    );

    test('does not unsubscribe from the publisher if there are still '
        'subscribers after some having unsubscribed', () {
      var sourceUnsubCalled = false;
      final source = _CallbackDataPublisher(
        onSubscribe: (channelName, subscriber) {
          return () {
            sourceUnsubCalled = true;
          };
        },
      );

      final demuxed = demultiplexDataPublisher<Object?>(
        sourcePublisher: source,
        sourceChannelName: 'channelName',
        messageTransformer: (_) => null,
      );

      final unsubscribe = demuxed.on('someChannelName', (_) {});
      demuxed.on('someChannelName', (_) {});
      unsubscribe();
      expect(sourceUnsubCalled, isFalse);
    });

    test("does not unsubscribe from the publisher when one subscriber's "
        'unsubscribe function is called as many times as there are '
        'subscriptions', () {
      var sourceUnsubCalled = false;
      final source = _CallbackDataPublisher(
        onSubscribe: (channelName, subscriber) {
          return () {
            sourceUnsubCalled = true;
          };
        },
      );

      final demuxed = demultiplexDataPublisher<Object?>(
        sourcePublisher: source,
        sourceChannelName: 'channelName',
        messageTransformer: (_) => null,
      );

      final unsubscribeA = demuxed.on('someChannelName', (_) {});
      demuxed.on('someOtherChannelName', (_) {});

      // No matter how many times the unsubscribe function is called, it only
      // decrements the subscriber count once, for its own subscription.
      unsubscribeA();
      unsubscribeA();
      expect(sourceUnsubCalled, isFalse);
    });

    test('publishes a message on the demuxed channel with the name returned '
        'by the transformer', () {
      final demuxed = demultiplexDataPublisher<Object?>(
        sourcePublisher: mockPublisher,
        sourceChannelName: 'channelName',
        messageTransformer: (_) => ('transformedChannelName', 'HI'),
      );

      Object? received;
      demuxed.on('transformedChannelName', (data) {
        received = data;
      });

      mockPublisher.publish('channelName', 'hi');
      expect(received, 'HI');
    });

    test('publishes no message on the demuxed channel if the transformer '
        'returns null', () {
      final demuxed = demultiplexDataPublisher<Object?>(
        sourcePublisher: mockPublisher,
        sourceChannelName: 'channelName',
        messageTransformer: (_) => null,
      );

      var called = false;
      demuxed.on('transformedChannelName', (_) {
        called = true;
      });

      mockPublisher.publish('channelName', 'hi');
      expect(called, isFalse);
    });

    test('calls the transform function for every matching event', () {
      var transformCallCount = 0;
      demultiplexDataPublisher<Object?>(
        sourcePublisher: mockPublisher,
        sourceChannelName: 'channelName',
        messageTransformer: (message) {
          transformCallCount++;
          return null;
        },
      ).on('channelName', (_) {});
      mockPublisher
        ..publish('channelName', 'first')
        ..publish('channelName', 'second');
      expect(transformCallCount, 2);
    });

    test('passes the source message to the transformer', () {
      Object? transformedMessage;
      demultiplexDataPublisher<Object?>(
        sourcePublisher: mockPublisher,
        sourceChannelName: 'channelName',
        messageTransformer: (message) {
          transformedMessage = message;
          return null;
        },
      ).on('channelName', (_) {});
      mockPublisher.publish('channelName', 'hi');
      expect(transformedMessage, 'hi');
    });

    test('re-subscribes to source after all subscribers leave and a new one '
        'appears', () {
      var sourceSubCount = 0;
      final source = _CallbackDataPublisher(
        onSubscribe: (channelName, subscriber) {
          sourceSubCount++;
          return () {};
        },
      );

      final demuxed = demultiplexDataPublisher<Object?>(
        sourcePublisher: source,
        sourceChannelName: 'channelName',
        messageTransformer: (_) => null,
      );

      final unsub1 = demuxed.on('channel1', (_) {});
      expect(sourceSubCount, 1);

      unsub1();

      demuxed.on('channel2', (_) {});
      expect(sourceSubCount, 2);
    });
  });
}

/// A [DataPublisher] that delegates to a callback for testing.
class _CallbackDataPublisher implements DataPublisher {
  const _CallbackDataPublisher({required this.onSubscribe});

  final UnsubscribeFn Function(
    String channelName,
    Subscriber<Object?> subscriber,
  )
  onSubscribe;

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    return onSubscribe(channelName, subscriber);
  }
}

/// A [DataPublisher] that wraps another and tracks calls to [on].
class _TrackingDataPublisher implements DataPublisher {
  _TrackingDataPublisher(this._inner, {required this.onCall});

  final DataPublisher _inner;
  final void Function(UnsubscribeFn unsub) onCall;

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    final unsub = _inner.on(channelName, subscriber);
    onCall(unsub);
    return unsub;
  }
}
