import 'dart:async';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('PendingRpcSubscriptionsRequest', () {
    test('subscribe wires plan request/abort signal into transport', () async {
      RpcSubscriptionsTransportConfig? capturedConfig;
      final publisher = createDataPublisher();
      Future<DataPublisher> transport(
        RpcSubscriptionsTransportConfig config,
      ) async {
        capturedConfig = config;
        return publisher;
      }

      final plan = RpcSubscriptionsPlan<Object?>(
        execute: (_) async => createDataPublisher(),
        request: const RpcSubscriptionsRequest(
          methodName: 'accountNotifications',
          params: ['11111111111111111111111111111111'],
        ),
      );

      final pending = PendingRpcSubscriptionsRequest<Object?>(
        transport: transport,
        plan: plan,
      );
      final abortController = AbortController();
      final stream = await pending.subscribe(
        RpcSubscribeOptions(abortSignal: abortController.signal),
      );

      expect(capturedConfig, isNotNull);
      expect(capturedConfig!.request.methodName, 'accountNotifications');
      expect(
        capturedConfig!.request.params,
        ['11111111111111111111111111111111'],
      );
      expect(capturedConfig!.signal, same(abortController.signal));

      final firstEvent = stream.first;
      publisher.publish('notification', {'slot': 123});
      expect(await firstEvent, {'slot': 123});
    });

    test('subscribe forwards error events from the data publisher', () async {
      final publisher = createDataPublisher();
      final pending = PendingRpcSubscriptionsRequest<Object?>(
        transport: (_) async => publisher,
        plan: RpcSubscriptionsPlan<Object?>(
          execute: (_) async => createDataPublisher(),
          request: const RpcSubscriptionsRequest(
            methodName: 'logsNotifications',
            params: [],
          ),
        ),
      );

      final stream = await pending.subscribe(
        RpcSubscribeOptions(abortSignal: AbortController().signal),
      );
      final errorCompleter = Completer<Object?>();
      final subscription = stream.listen(
        (_) {},
        onError: errorCompleter.complete,
      );

      publisher.publish('error', 'boom');
      expect(await errorCompleter.future, 'boom');

      await subscription.cancel();
    });
  });

  group('RpcSubscriptions.request', () {
    test('throws SolanaError when API cannot build a plan', () {
      final subscriptions = RpcSubscriptions(
        api: _TestApi(),
        transport: (_) async => createDataPublisher(),
      );

      expect(
        () => subscriptions.request('unknownNotifications'),
        throwsA(
          isA<SolanaError>()
              .having(
                (error) => error.code,
                'code',
                SolanaErrorCode.rpcSubscriptionsCannotCreateSubscriptionPlan,
              )
              .having(
                (error) => error.context['notificationName'],
                'notificationName',
                'unknownNotifications',
              ),
        ),
      );
    });

    test('returns a pending request when plan exists', () {
      final subscriptions = RpcSubscriptions(
        api: _TestApi(
          plans: {
            'slotNotifications': RpcSubscriptionsPlan<Object?>(
              execute: (_) async => createDataPublisher(),
              request: const RpcSubscriptionsRequest(
                methodName: 'slotNotifications',
                params: [],
              ),
            ),
          },
        ),
        transport: (_) async => createDataPublisher(),
      );

      final pending = subscriptions.request('slotNotifications');
      expect(pending, isA<PendingRpcSubscriptionsRequest<Object?>>());
    });
  });

  group('typed subscription methods', () {
    test('accountNotifications builds method-specific params', () async {
      RpcSubscriptionsTransportConfig? capturedConfig;
      Future<DataPublisher> transport(
        RpcSubscriptionsTransportConfig config,
      ) async {
        capturedConfig = config;
        return createDataPublisher();
      }

      final rpc = createSolanaRpcSubscriptionsFromTransport(transport);
      await rpc
          .accountNotifications(
            const Address('11111111111111111111111111111111'),
            const AccountNotificationsConfig(
              encoding: 'base64',
              commitment: Commitment.confirmed,
            ),
          )
          .subscribe(RpcSubscribeOptions(abortSignal: AbortController().signal));

      expect(capturedConfig, isNotNull);
      expect(capturedConfig!.request.methodName, 'accountNotifications');
      expect(capturedConfig!.request.params, [
        '11111111111111111111111111111111',
        {'encoding': 'base64', 'commitment': 'confirmed'},
      ]);
    });

    test('slotNotifications builds empty params', () async {
      RpcSubscriptionsTransportConfig? capturedConfig;
      Future<DataPublisher> transport(
        RpcSubscriptionsTransportConfig config,
      ) async {
        capturedConfig = config;
        return createDataPublisher();
      }

      final rpc = createSolanaRpcSubscriptionsFromTransport(transport);
      await rpc
          .slotNotifications()
          .subscribe(RpcSubscribeOptions(abortSignal: AbortController().signal));

      expect(capturedConfig, isNotNull);
      expect(capturedConfig!.request.methodName, 'slotNotifications');
      expect(capturedConfig!.request.params, isEmpty);
    });

    test('signatureNotifications builds method-specific params', () async {
      RpcSubscriptionsTransportConfig? capturedConfig;
      Future<DataPublisher> transport(
        RpcSubscriptionsTransportConfig config,
      ) async {
        capturedConfig = config;
        return createDataPublisher();
      }

      final rpc = createSolanaRpcSubscriptionsFromTransport(transport);
      await rpc
          .signatureNotifications(
            const Signature('test-signature'),
            const SignatureNotificationsConfig(
              commitment: Commitment.confirmed,
              enableReceivedNotification: true,
            ),
          )
          .subscribe(RpcSubscribeOptions(abortSignal: AbortController().signal));

      expect(capturedConfig, isNotNull);
      expect(capturedConfig!.request.methodName, 'signatureNotifications');
      expect(capturedConfig!.request.params, [
        'test-signature',
        {'commitment': 'confirmed', 'enableReceivedNotification': true},
      ]);
    });
  });

  group('factory functions', () {
    test('createSubscriptionRpc preserves api and transport references', () {
      final api = _TestApi();
      Future<DataPublisher> transport(
        RpcSubscriptionsTransportConfig _,
      ) async => createDataPublisher();
      final rpc = createSubscriptionRpc(
        RpcSubscriptionsConfig(api: api, transport: transport),
      );

      expect(rpc.api, same(api));
      expect(rpc.transport, same(transport));
    });

    test(
      'createSolanaRpcSubscriptionsFromTransport builds passthrough plans',
      () async {
        RpcSubscriptionsTransportConfig? capturedConfig;
        Future<DataPublisher> transport(
          RpcSubscriptionsTransportConfig config,
        ) async {
          capturedConfig = config;
          return createDataPublisher();
        }

        final rpc = createSolanaRpcSubscriptionsFromTransport(transport);
        final pending = rpc.request('accountNotifications', ['pubkey', 'json']);
        await pending.subscribe(
          RpcSubscribeOptions(abortSignal: AbortController().signal),
        );

        expect(capturedConfig, isNotNull);
        expect(capturedConfig!.request.methodName, 'accountNotifications');
        expect(capturedConfig!.request.params, ['pubkey', 'json']);

        final channel = _MockChannel();
        final executeResult = await capturedConfig!.execute(
          RpcSubscriptionsTransportExecuteConfig(
            channel: channel,
            signal: AbortController().signal,
          ),
        );
        expect(executeResult, same(channel));
      },
    );

    test('stable and unstable Solana factories return RpcSubscriptions', () {
      final stable = createSolanaRpcSubscriptions('ws://localhost:8900');
      final unstable = createSolanaRpcSubscriptionsUnstable(
        'wss://api.devnet.solana.com',
      );

      expect(stable, isA<RpcSubscriptions>());
      expect(unstable, isA<RpcSubscriptions>());
      expect(
        stable.request('accountNotifications', ['pubkey']),
        isA<PendingRpcSubscriptionsRequest<Object?>>(),
      );
      expect(
        unstable.request('voteNotifications'),
        isA<PendingRpcSubscriptionsRequest<Object?>>(),
      );
    });
  });
}

class _TestApi extends RpcSubscriptionsApi {
  _TestApi({Map<String, RpcSubscriptionsPlan<Object?>>? plans})
    : _plans = plans ?? const {};

  final Map<String, RpcSubscriptionsPlan<Object?>> _plans;

  @override
  RpcSubscriptionsPlan<Object?>? getPlan(
    String notificationName,
    List<Object?> params,
  ) {
    return _plans[notificationName];
  }
}

class _MockChannel implements RpcSubscriptionsChannel {
  _MockChannel() : _publisher = createDataPublisher();

  final WritableDataPublisher _publisher;

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    return _publisher.on(channelName, subscriber);
  }

  @override
  Future<void> send(Object message) async {}
}
