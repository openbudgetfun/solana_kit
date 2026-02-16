import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

const _mockIntervalMs = 60000;

void main() {
  group('getRpcSubscriptionsChannelWithAutoping', () {
    late _MockChannel mockChannel;
    late WritableDataPublisher dataPublisher;

    void receiveError([Object? error]) {
      dataPublisher.publish('error', error);
    }

    void receiveMessage(Object? message) {
      dataPublisher.publish('message', message);
    }

    setUp(() {
      dataPublisher = createDataPublisher();
      mockChannel = _MockChannel(dataPublisher: dataPublisher);
    });

    test('sends a ping message to the channel at the specified interval', () {
      FakeAsync().run((async) {
        getRpcSubscriptionsChannelWithAutoping(
          abortSignal: AbortController().signal,
          channel: mockChannel,
          intervalMs: _mockIntervalMs,
        );

        // Not yet at the first ping interval.
        async.elapse(const Duration(milliseconds: _mockIntervalMs - 1));
        expect(mockChannel.sendCallCount, equals(0));

        // First ping.
        async.elapse(const Duration(milliseconds: 1));
        expect(mockChannel.sendCallCount, equals(1));
        expect(
          mockChannel.lastSentMessage,
          isA<Map<String, Object>>()
              .having((m) => m['jsonrpc'], 'jsonrpc', '2.0')
              .having((m) => m['method'], 'method', 'ping'),
        );

        // Second ping.
        mockChannel.resetCallCount();
        async.elapse(const Duration(milliseconds: _mockIntervalMs - 1));
        expect(mockChannel.sendCallCount, equals(0));

        async.elapse(const Duration(milliseconds: 1));
        expect(mockChannel.sendCallCount, equals(1));
        expect(
          mockChannel.lastSentMessage,
          isA<Map<String, Object>>()
              .having((m) => m['jsonrpc'], 'jsonrpc', '2.0')
              .having((m) => m['method'], 'method', 'ping'),
        );
      });
    });

    test(
      'continues to ping even though send fataled with a non-connection-closed'
      ' exception',
      () {
        FakeAsync().run((async) {
          mockChannel.sendError = 'o no';

          getRpcSubscriptionsChannelWithAutoping(
            abortSignal: AbortController().signal,
            channel: mockChannel,
            intervalMs: _mockIntervalMs,
          );

          // First ping (will fail with non-connection-closed error).
          async
            ..elapse(const Duration(milliseconds: _mockIntervalMs))
            ..flushMicrotasks();

          // Second ping should still fire.
          mockChannel.resetCallCount();
          async.elapse(const Duration(milliseconds: _mockIntervalMs));
          expect(mockChannel.sendCallCount, equals(1));
        });
      },
    );

    test('does not send a ping until interval milliseconds after the last sent '
        'message', () {
      FakeAsync().run((async) {
        final autopingChannel = getRpcSubscriptionsChannelWithAutoping(
          abortSignal: AbortController().signal,
          channel: mockChannel,
          intervalMs: _mockIntervalMs,
        );

        // Send a message, which should reset the timer.
        unawaited(autopingChannel.send('hi'));
        mockChannel.resetCallCount();

        async.elapse(const Duration(milliseconds: 500));
        expect(mockChannel.sendCallCount, equals(0));

        // Send another message, resetting the timer again.
        unawaited(autopingChannel.send('hi'));
        mockChannel.resetCallCount();

        async.elapse(const Duration(milliseconds: _mockIntervalMs - 1));
        expect(mockChannel.sendCallCount, equals(0));

        async.elapse(const Duration(milliseconds: 1));
        expect(mockChannel.sendCallCount, equals(1));
        expect(
          mockChannel.lastSentMessage,
          isA<Map<String, Object>>().having(
            (m) => m['method'],
            'method',
            'ping',
          ),
        );
      });
    });

    test('does not send a ping until interval milliseconds after the last '
        'received message', () {
      FakeAsync().run((async) {
        getRpcSubscriptionsChannelWithAutoping(
          abortSignal: AbortController().signal,
          channel: mockChannel,
          intervalMs: _mockIntervalMs,
        );

        async.elapse(const Duration(milliseconds: 500));
        expect(mockChannel.sendCallCount, equals(0));

        // Receive a message, which should reset the timer.
        receiveMessage('hi');

        async.elapse(const Duration(milliseconds: _mockIntervalMs - 1));
        expect(mockChannel.sendCallCount, equals(0));

        async.elapse(const Duration(milliseconds: 1));
        expect(mockChannel.sendCallCount, equals(1));
        expect(
          mockChannel.lastSentMessage,
          isA<Map<String, Object>>().having(
            (m) => m['method'],
            'method',
            'ping',
          ),
        );
      });
    });

    test('does not send a ping after a channel error', () {
      FakeAsync().run((async) {
        getRpcSubscriptionsChannelWithAutoping(
          abortSignal: AbortController().signal,
          channel: mockChannel,
          intervalMs: _mockIntervalMs,
        );

        // First ping.
        async.elapse(const Duration(milliseconds: _mockIntervalMs));
        expect(mockChannel.sendCallCount, equals(1));

        receiveError('o no');
        async.flushMicrotasks();

        // No more pings.
        mockChannel.resetCallCount();
        async.elapse(const Duration(milliseconds: _mockIntervalMs));
        expect(mockChannel.sendCallCount, equals(0));
      });
    });

    test(
      'does not send a ping after send fatals with a connection closed error',
      () {
        FakeAsync().run((async) {
          mockChannel.sendError = SolanaError(
            SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed,
          );

          getRpcSubscriptionsChannelWithAutoping(
            abortSignal: AbortController().signal,
            channel: mockChannel,
            intervalMs: _mockIntervalMs,
          );

          // First ping (will fail with connection closed error).
          async
            ..elapse(const Duration(milliseconds: _mockIntervalMs))
            ..flushMicrotasks();

          // No more pings.
          mockChannel.resetCallCount();
          async.elapse(const Duration(milliseconds: _mockIntervalMs));
          expect(mockChannel.sendCallCount, equals(0));
        });
      },
    );

    test('does not send a ping after the abort signal fires', () {
      FakeAsync().run((async) {
        final abortController = AbortController();

        getRpcSubscriptionsChannelWithAutoping(
          abortSignal: abortController.signal,
          channel: mockChannel,
          intervalMs: _mockIntervalMs,
        );

        // First ping.
        async.elapse(const Duration(milliseconds: _mockIntervalMs));
        expect(mockChannel.sendCallCount, equals(1));

        abortController.abort();
        async.flushMicrotasks();

        // No more pings.
        mockChannel.resetCallCount();
        async.elapse(const Duration(milliseconds: _mockIntervalMs));
        expect(mockChannel.sendCallCount, equals(0));
      });
    });
  });
}

class _MockChannel implements RpcSubscriptionsChannel {
  _MockChannel({required this.dataPublisher});

  final WritableDataPublisher dataPublisher;
  Object? lastSentMessage;
  int sendCallCount = 0;
  Object? sendError;

  void resetCallCount() {
    sendCallCount = 0;
    lastSentMessage = null;
  }

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    return dataPublisher.on(channelName, subscriber);
  }

  @override
  Future<void> send(Object message) {
    sendCallCount++;
    lastSentMessage = message;
    if (sendError != null) {
      return Future<void>.error(sendError!);
    }
    return Future<void>.value();
  }
}
