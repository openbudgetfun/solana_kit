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
          abortSignal: CancellationTokenSource().token,
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
          abortSignal: CancellationTokenSource().token,
        );
        final channelB = await poolingChannelCreator(
          abortSignal: CancellationTokenSource().token,
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
          poolingChannelCreator(abortSignal: CancellationTokenSource().token),
          poolingChannelCreator(abortSignal: CancellationTokenSource().token),
        ]);

        expect(results[0], same(results[1]));
      },
    );

    test(
      'fires a created channel cancellation token when the outer token is '
      'cancelled',
      () async {
        final poolingChannelCreator = getChannelPoolingChannelCreator(
          createChannel.create,
          maxSubscriptionsPerChannel: 9007199254740991,
          minChannels: 1,
        );

        final source = CancellationTokenSource();
        await poolingChannelCreator(abortSignal: source.token);

        source.cancel();

        // Wait for microtasks.
        await Future<void>.delayed(Duration.zero);

        expect(createChannel.lastAbortSignal?.isCancelled, isTrue);
      },
    );

    test(
      'fires a created channel cancellation token when the outer token is '
      'cancelled within the runloop',
      () async {
        final poolingChannelCreator = getChannelPoolingChannelCreator(
          createChannel.create,
          maxSubscriptionsPerChannel: 9007199254740991,
          minChannels: 1,
        );

        final source = CancellationTokenSource();
        poolingChannelCreator(abortSignal: source.token).ignore();

        source.cancel();

        // Wait for microtasks.
        await Future<void>.delayed(Duration.zero);

        expect(createChannel.lastAbortSignal?.isCancelled, isTrue);
      },
    );

    test('creates a new channel when the existing one already has '
        'maxSubscriptionsPerChannel consumers', () async {
      final poolingChannelCreator = getChannelPoolingChannelCreator(
        createChannel.create,
        maxSubscriptionsPerChannel: 1,
        minChannels: 1,
      );

      poolingChannelCreator(
        abortSignal: CancellationTokenSource().token,
      ).ignore();
      poolingChannelCreator(
        abortSignal: CancellationTokenSource().token,
      ).ignore();

      expect(createChannel.callCount, equals(2));
    });

    test('destroys a channel when the last subscriber aborts', () async {
      final poolingChannelCreator = getChannelPoolingChannelCreator(
        createChannel.create,
        maxSubscriptionsPerChannel: 9007199254740991,
        minChannels: 1,
      );

      final source = CancellationTokenSource();
      poolingChannelCreator(abortSignal: source.token).ignore();

      // Wait for channel creation.
      await Future<void>.delayed(Duration.zero);

      expect(createChannel.callCount, equals(1));

      source.cancel();

      // Wait for the abort to propagate.
      await Future<void>.delayed(Duration.zero);

      // The channel's own cancellation token should have fired.
      expect(createChannel.lastAbortSignal?.isCancelled, isTrue);
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
        abortSignal: CancellationTokenSource().token,
      );
      final channelB = poolingChannelCreator(
        abortSignal: CancellationTokenSource().token,
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

      poolingChannelCreator(
        abortSignal: CancellationTokenSource().token,
      ).ignore();
      poolingChannelCreator(
        abortSignal: CancellationTokenSource().token,
      ).ignore();

      // Wait for channels to open and error listeners to attach.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Fire errors on all listeners.
      for (final listener in errorListeners) {
        listener('o no');
      }

      // After error, the channel's cancellation token should be fired.
      expect(createChannel.lastAbortSignal?.isCancelled, isTrue);
    });
  });
}

class _MockChannel implements RpcSubscriptionsChannel {
  _MockChannel({this.onErrorListener});

  final void Function(void Function(Object?))? onErrorListener;
  final StreamController<Object?> _messagesController =
      StreamController<Object?>.broadcast(sync: true);
  late final StreamController<Object?> _errorsController =
      StreamController<Object?>.broadcast(
        sync: true,
        onListen: () {
          onErrorListener?.call((callback) {
            _errorsController.add(null);
          });
        },
      );

  @override
  NotificationStreams get streams => NotificationStreams(
    notifications: _messagesController.stream,
    errors: _errorsController.stream,
  );

  @override
  Future<void> send(Object message) async {}
}

class _MockChannelCreator {
  int callCount = 0;
  CancellationToken? lastAbortSignal;
  bool shouldFail = false;
  final List<_MockChannel> nextChannels = [];
  void Function(void Function(Object?))? onErrorListener;

  Future<RpcSubscriptionsChannel> create({
    required CancellationToken abortSignal,
  }) {
    callCount++;
    lastAbortSignal = abortSignal;

    if (shouldFail) {
      return Future.error('o no');
    }

    final channel = nextChannels.isNotEmpty
        ? nextChannels.removeAt(0)
        : _MockChannel(
            onErrorListener: onErrorListener,
          );
    return Future.value(channel);
  }
}
