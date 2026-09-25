import 'dart:async';

import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('createRpcSubscriptionsTransportFromChannelCreator', () {
    test(
      'creates a function that calls createChannel with the cancellation token',
      () {
        CancellationToken? capturedSignal;
        Future<RpcSubscriptionsChannel> mockCreateChannel({
          required CancellationToken abortSignal,
        }) {
          capturedSignal = abortSignal;
          return Completer<RpcSubscriptionsChannel>().future;
        }

        final creator = createRpcSubscriptionsTransportFromChannelCreator(
          mockCreateChannel,
        );

        final source = CancellationTokenSource();
        creator(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => mockStreams(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: source.token,
          ),
        ).ignore();

        expect(capturedSignal, same(source.token));
      },
    );

    test(
      'creates a function that calls execute with the created channel',
      () async {
        final mockChannel = _MockChannel();
        Future<RpcSubscriptionsChannel> mockCreateChannel({
          required CancellationToken abortSignal,
        }) async {
          return mockChannel;
        }

        final creator = createRpcSubscriptionsTransportFromChannelCreator(
          mockCreateChannel,
        );

        RpcSubscriptionsTransportExecuteConfig? capturedConfig;
        creator(
          RpcSubscriptionsTransportConfig(
            execute: (config) async {
              capturedConfig = config;
              return mockStreams();
            },
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: CancellationTokenSource().token,
          ),
        ).ignore();

        // Wait for the async operations to complete.
        await Future<void>.delayed(Duration.zero);

        expect(capturedConfig, isNotNull);
        expect(capturedConfig!.channel, same(mockChannel));
      },
    );

    test(
      'creates a function that calls execute with the cancellation token',
      () async {
        final mockChannel = _MockChannel();
        Future<RpcSubscriptionsChannel> mockCreateChannel({
          required CancellationToken abortSignal,
        }) async {
          return mockChannel;
        }

        final creator = createRpcSubscriptionsTransportFromChannelCreator(
          mockCreateChannel,
        );

        final source = CancellationTokenSource();
        RpcSubscriptionsTransportExecuteConfig? capturedConfig;

        creator(
          RpcSubscriptionsTransportConfig(
            execute: (config) async {
              capturedConfig = config;
              return mockStreams();
            },
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: source.token,
          ),
        ).ignore();

        // Wait for the async operations to complete.
        await Future<void>.delayed(Duration.zero);

        expect(capturedConfig, isNotNull);
        expect(capturedConfig!.signal, same(source.token));
      },
    );
  });
}

NotificationStreams mockStreams() {
  final messages = StreamController<Object?>.broadcast(sync: true);
  final errors = StreamController<Object?>.broadcast(sync: true);
  return NotificationStreams(
    notifications: messages.stream,
    errors: errors.stream,
  );
}

class _MockChannel implements RpcSubscriptionsChannel {
  @override
  NotificationStreams get streams => const NotificationStreams(
    notifications: Stream<Object?>.empty(),
    errors: Stream<Object?>.empty(),
  );

  @override
  Future<void> send(Object message) async {}
}
