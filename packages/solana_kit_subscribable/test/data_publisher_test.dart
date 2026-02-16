import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('DataPublisher', () {
    late WritableDataPublisher publisher;

    setUp(() {
      publisher = createDataPublisher();
    });

    test('calls a subscriber with the published data', () {
      Object? received;
      publisher
        ..on('someEvent', (data) {
          received = data;
        })
        ..publish('someEvent', 123);
      expect(received, 123);
    });

    test('calls a subscriber with null data', () {
      Object? received = 'sentinel';
      publisher
        ..on('someEvent', (data) {
          received = data;
        })
        ..publish('someEvent', null);
      expect(received, isNull);
    });

    test(
      'does not call a subscriber after the unsubscribe function is called',
      () {
        var callCount = 0;
        final unsubscribe = publisher.on('someEvent', (_) {
          callCount++;
        });
        unsubscribe();
        publisher.publish('someEvent', 'data');
        expect(callCount, 0);
      },
    );

    test(
      'does not fatal when the unsubscribe method is called more than once',
      () {
        final unsubscribe = publisher.on('someEvent', (_) {});
        unsubscribe();
        expect(unsubscribe, returnsNormally);
      },
    );

    test(
      'keeps other subscribers subscribed when unsubscribing from others',
      () {
        var calledA = false;
        var calledB = false;
        publisher.on('someEvent', (_) {
          calledA = true;
        });
        final unsubscribeB = publisher.on('someEvent', (_) {
          calledB = true;
        });
        unsubscribeB();
        publisher.publish('someEvent', 'data');
        expect(calledA, isTrue);
        expect(calledB, isFalse);
      },
    );

    test('does not notify a subscriber about an event with a type different '
        'than the one it is interested in', () {
      var called = false;
      publisher
        ..on('someEvent', (_) {
          called = true;
        })
        ..publish('someOtherEvent', 'data');
      expect(called, isFalse);
    });

    test('supports multiple subscribers on the same channel', () {
      var countA = 0;
      var countB = 0;
      publisher
        ..on('channel', (_) {
          countA++;
        })
        ..on('channel', (_) {
          countB++;
        })
        ..publish('channel', 'data');
      expect(countA, 1);
      expect(countB, 1);
    });

    test('passes published data to all subscribers on the channel', () {
      final received = <Object?>[];
      publisher
        ..on('channel', received.add)
        ..on('channel', received.add)
        ..publish('channel', 42);
      expect(received, [42, 42]);
    });

    test('different channels are independent', () {
      Object? receivedA;
      Object? receivedB;
      publisher
        ..on('channelA', (data) {
          receivedA = data;
        })
        ..on('channelB', (data) {
          receivedB = data;
        })
        ..publish('channelA', 'hello');
      expect(receivedA, 'hello');
      expect(receivedB, isNull);
    });

    test('does nothing when publishing to a channel with no subscribers', () {
      // Should not throw.
      publisher.publish('nonexistent', 'data');
    });

    test('subscriber can unsubscribe during notification', () {
      late UnsubscribeFn unsub;
      var callCount = 0;
      unsub = publisher.on('channel', (_) {
        callCount++;
        unsub();
      });
      publisher
        ..publish('channel', 'first')
        ..publish('channel', 'second');
      expect(callCount, 1);
    });
  });
}
