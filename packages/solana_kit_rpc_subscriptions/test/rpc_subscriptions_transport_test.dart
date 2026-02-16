import 'dart:async';

import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('createRpcSubscriptionsTransportFromChannelCreator', () {
    test(
      'creates a function that calls createChannel with the abort signal',
      () {
        AbortSignal? capturedSignal;
        Future<RpcSubscriptionsChannel> mockCreateChannel({
          required AbortSignal abortSignal,
        }) {
          capturedSignal = abortSignal;
          return Completer<RpcSubscriptionsChannel>().future;
        }

        final creator = createRpcSubscriptionsTransportFromChannelCreator(
          mockCreateChannel,
        );

        final abortController = AbortController();
        creator(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => createDataPublisher(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: abortController.signal,
          ),
        ).ignore();

        expect(capturedSignal, same(abortController.signal));
      },
    );

    test(
      'creates a function that calls execute with the created channel',
      () async {
        final mockChannel = _MockChannel();
        Future<RpcSubscriptionsChannel> mockCreateChannel({
          required AbortSignal abortSignal,
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
              return createDataPublisher();
            },
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: AbortController().signal,
          ),
        ).ignore();

        // Wait for the async operations to complete.
        await Future<void>.delayed(Duration.zero);

        expect(capturedConfig, isNotNull);
        expect(capturedConfig!.channel, same(mockChannel));
      },
    );

    test(
      'creates a function that calls execute with the abort signal',
      () async {
        final mockChannel = _MockChannel();
        Future<RpcSubscriptionsChannel> mockCreateChannel({
          required AbortSignal abortSignal,
        }) async {
          return mockChannel;
        }

        final creator = createRpcSubscriptionsTransportFromChannelCreator(
          mockCreateChannel,
        );

        final abortController = AbortController();
        RpcSubscriptionsTransportExecuteConfig? capturedConfig;

        creator(
          RpcSubscriptionsTransportConfig(
            execute: (config) async {
              capturedConfig = config;
              return createDataPublisher();
            },
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: abortController.signal,
          ),
        ).ignore();

        // Wait for the async operations to complete.
        await Future<void>.delayed(Duration.zero);

        expect(capturedConfig, isNotNull);
        expect(capturedConfig!.signal, same(abortController.signal));
      },
    );
  });
}

class _MockChannel implements RpcSubscriptionsChannel {
  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    return () {};
  }

  @override
  Future<void> send(Object message) async {}
}
