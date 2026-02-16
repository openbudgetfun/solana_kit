import 'dart:async';

import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('getChannelPoolingChannelCreator', () {
    late _MockChannelCreator createChannel;

    setUp(() {
      createChannel = _MockChannelCreator();
    });

    test(
      'creates a new channel when there are fewer than minChannels',
      () async {
        final newChannel = _MockChannel();
        createChannel.nextChannels.add(newChannel);

        final poolingChannelCreator = getChannelPoolingChannelCreator(
          createChannel.create,
          maxSubscriptionsPerChannel: 9007199254740991,
          minChannels: 1,
        );

        final result = await poolingChannelCreator(
          abortSignal: AbortController().signal,
        );

        expect(createChannel.callCount, equals(1));
        expect(result, same(newChannel));
      },
    );

    test(
      'vends an existing channel when called in a separate runloop',
      () async {
        final poolingChannelCreator = getChannelPoolingChannelCreator(
          createChannel.create,
          maxSubscriptionsPerChannel: 9007199254740991,
          minChannels: 1,
        );

        final channelA = await poolingChannelCreator(
          abortSignal: AbortController().signal,
        );
        final channelB = await poolingChannelCreator(
          abortSignal: AbortController().signal,
        );

        expect(channelA, same(channelB));
      },
    );

    test(
      'vends an existing channel when called concurrently in the same runloop',
      () async {
        final poolingChannelCreator = getChannelPoolingChannelCreator(
          createChannel.create,
          maxSubscriptionsPerChannel: 9007199254740991,
          minChannels: 1,
        );

        final results = await Future.wait([
          poolingChannelCreator(abortSignal: AbortController().signal),
          poolingChannelCreator(abortSignal: AbortController().signal),
        ]);

        expect(results[0], same(results[1]));
      },
    );

    test(
      'fires a created channel abort signal when the outer signal is aborted',
      () async {
        final poolingChannelCreator = getChannelPoolingChannelCreator(
          createChannel.create,
          maxSubscriptionsPerChannel: 9007199254740991,
          minChannels: 1,
        );

        final abortController = AbortController();
        await poolingChannelCreator(abortSignal: abortController.signal);

        abortController.abort();

        // Wait for microtasks.
        await Future<void>.delayed(Duration.zero);

        expect(createChannel.lastAbortSignal?.isAborted, isTrue);
      },
    );

    test(
      'fires a created channel abort signal when the outer signal is aborted '
      'within the runloop',
      () async {
        final poolingChannelCreator = getChannelPoolingChannelCreator(
          createChannel.create,
          maxSubscriptionsPerChannel: 9007199254740991,
          minChannels: 1,
        );

        final abortController = AbortController();
        poolingChannelCreator(abortSignal: abortController.signal).ignore();

        abortController.abort();

        // Wait for microtasks.
        await Future<void>.delayed(Duration.zero);

        expect(createChannel.lastAbortSignal?.isAborted, isTrue);
      },
    );

    test('creates a new channel when the existing one already has '
        'maxSubscriptionsPerChannel consumers', () async {
      final poolingChannelCreator = getChannelPoolingChannelCreator(
        createChannel.create,
        maxSubscriptionsPerChannel: 1,
        minChannels: 1,
      );

      poolingChannelCreator(abortSignal: AbortController().signal).ignore();
      poolingChannelCreator(abortSignal: AbortController().signal).ignore();

      expect(createChannel.callCount, equals(2));
    });

    test('destroys a channel when the last subscriber aborts', () async {
      final poolingChannelCreator = getChannelPoolingChannelCreator(
        createChannel.create,
        maxSubscriptionsPerChannel: 9007199254740991,
        minChannels: 1,
      );

      final abortController = AbortController();
      poolingChannelCreator(abortSignal: abortController.signal).ignore();

      // Wait for channel creation.
      await Future<void>.delayed(Duration.zero);

      expect(createChannel.callCount, equals(1));

      abortController.abort();

      // Wait for the abort to propagate.
      await Future<void>.delayed(Duration.zero);

      // The channel's own abort signal should have fired.
      expect(createChannel.lastAbortSignal?.isAborted, isTrue);
    });

    test('does not create a channel pool entry when the channel fails to '
        'construct', () async {
      createChannel.shouldFail = true;

      final poolingChannelCreator = getChannelPoolingChannelCreator(
        createChannel.create,
        maxSubscriptionsPerChannel: 9007199254740991,
        minChannels: 1,
      );

      final channelA = poolingChannelCreator(
        abortSignal: AbortController().signal,
      );
      final channelB = poolingChannelCreator(
        abortSignal: AbortController().signal,
      );

      await expectLater(channelA, throwsA(equals('o no')));
      await expectLater(channelB, throwsA(equals('o no')));
    });

    test('destroys a channel pool entry when the channel encounters an error '
        'message', () async {
      final errorListeners = <void Function(Object?)>[];
      createChannel.onErrorListener = errorListeners.add;

      final poolingChannelCreator = getChannelPoolingChannelCreator(
        createChannel.create,
        maxSubscriptionsPerChannel: 9007199254740991,
        minChannels: 1,
      );

      poolingChannelCreator(abortSignal: AbortController().signal).ignore();
      poolingChannelCreator(abortSignal: AbortController().signal).ignore();

      // Wait for channels to open and error listeners to attach.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Fire errors on all listeners.
      for (final listener in errorListeners) {
        listener('o no');
      }

      // After error, the channel's abort signal should be fired.
      expect(createChannel.lastAbortSignal?.isAborted, isTrue);
    });
  });
}

class _MockChannel implements RpcSubscriptionsChannel {
  _MockChannel({WritableDataPublisher? dataPublisher})
    : _dataPublisher = dataPublisher ?? createDataPublisher();

  final WritableDataPublisher _dataPublisher;
  void Function(void Function(Object?))? onErrorListener;

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    if (channelName == 'error' && onErrorListener != null) {
      onErrorListener!(subscriber);
    }
    return _dataPublisher.on(channelName, subscriber);
  }

  @override
  Future<void> send(Object message) async {}
}

class _MockChannelCreator {
  int callCount = 0;
  AbortSignal? lastAbortSignal;
  bool shouldFail = false;
  final List<_MockChannel> nextChannels = [];
  void Function(void Function(Object?))? onErrorListener;

  Future<RpcSubscriptionsChannel> create({required AbortSignal abortSignal}) {
    callCount++;
    lastAbortSignal = abortSignal;

    if (shouldFail) {
      return Future.error('o no');
    }

    final channel =
        nextChannels.isNotEmpty ? nextChannels.removeAt(0) : _MockChannel()
          ..onErrorListener = onErrorListener;
    return Future.value(channel);
  }
}
