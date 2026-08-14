import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  group('PendingRpcSubscriptionsRequest', () {
    test(
      'subscribe wires plan request/cancellation token into transport',
      () async {
        final captured = CapturingSubscriptionsTransport();
        final plan = RpcSubscriptionsPlan<Object?>(
          execute: (_) async => captured.streams,
          request: RpcSubscriptionsRequest(
            methodName: 'accountNotifications',
            params: [testAccountAddressB.value],
          ),
        );

        final pending = PendingRpcSubscriptionsRequest<Object?>(
          transport: captured.transport,
          plan: plan,
        );
        final source = CancellationTokenSource();
        final stream = await pending.subscribe(
          RpcSubscribeOptions(abortSignal: source.token),
        );

        expect(captured.lastConfig.request.methodName, 'accountNotifications');
        expect(captured.lastConfig.request.params, [testAccountAddressB.value]);
        expect(captured.lastConfig.signal, same(source.token));

        final firstEvent = stream.first;
        captured.publishNotification({'slot': 123});
        expect(await firstEvent, {'slot': 123});
      },
    );

    test(
      'reactiveStore returns a store backed by subscription notifications',
      () async {
        final captured = CapturingSubscriptionsTransport();
        final pending = PendingRpcSubscriptionsRequest<Object?>(
          transport: captured.transport,
          plan: const RpcSubscriptionsPlan<Object?>(
            execute: _planStreamsExecute,
            request: RpcSubscriptionsRequest(
              methodName: 'slotNotifications',
              params: [],
            ),
          ),
        );

        // v7: reactiveStore() is synchronous and starts idle; connect() opens
        // the subscription via the per-connection factory.
        final store = pending();
        expect(store.getState().status, ReactiveStreamState.idle);
        store.connect();
        expect(store.getState().status, ReactiveStreamState.loading);
        await Future<void>.delayed(Duration.zero);

        expect(captured.lastConfig.request.methodName, 'slotNotifications');
        expect(captured.lastConfig.signal, isA<CancellationToken>());

        var updates = 0;
        final unsubscribe = store.subscribe(() => updates++);
        captured
          ..publishNotification({'slot': 124})
          ..publishError('boom');
        await Future<void>.delayed(Duration.zero);

        expect(store.getState().data, {'slot': 124});
        expect(store.getState().error, 'boom');
        expect(updates, greaterThanOrEqualTo(2));

        unsubscribe();
        store.dispose();
      },
    );

    test(
      'subscribe forwards error events from the notification streams',
      () async {
        final captured = CapturingSubscriptionsTransport();
        final pending = PendingRpcSubscriptionsRequest<Object?>(
          transport: captured.transport,
          plan: const RpcSubscriptionsPlan<Object?>(
            execute: _planStreamsExecute,
            request: RpcSubscriptionsRequest(
              methodName: 'logsNotifications',
              params: [],
            ),
          ),
        );

        final stream = await pending.subscribe(
          RpcSubscribeOptions(abortSignal: CancellationTokenSource().token),
        );
        final errorCompleter = Completer<Object?>();
        final subscription = stream.listen(
          (_) {},
          onError: errorCompleter.complete,
        );

        captured.publishError('boom');
        expect(await errorCompleter.future, 'boom');

        await subscription.cancel();
      },
    );

    test('subscribe closes and detaches source streams after abort', () async {
      var notificationCancelCount = 0;
      var errorCancelCount = 0;
      final notifications = StreamController<Object?>.broadcast(
        onCancel: () => notificationCancelCount++,
        sync: true,
      );
      final errors = StreamController<Object?>.broadcast(
        onCancel: () => errorCancelCount++,
        sync: true,
      );
      final pending = _pendingRequestForTransport(
        (_) async => NotificationStreams(
          notifications: notifications.stream,
          errors: errors.stream,
        ),
      );
      final source = CancellationTokenSource();
      final received = <Object?>[];
      final receivedErrors = <Object>[];
      final done = Completer<void>();
      final stream = await pending.subscribe(
        RpcSubscribeOptions(abortSignal: source.token),
      );

      stream.listen(
        received.add,
        onError: receivedErrors.add,
        onDone: done.complete,
      );
      notifications.add('before');
      source.cancel();
      notifications.add('late');
      errors.add(StateError('late'));
      await done.future;

      expect(received, ['before']);
      expect(receivedErrors, isEmpty);
      expect(notificationCancelCount, 1);
      expect(errorCancelCount, 1);
      await notifications.close();
      await errors.close();
    });

    test(
      'subscribe closes before listening when aborted after acquisition',
      () async {
        var notificationListenCount = 0;
        var errorListenCount = 0;
        final notifications = StreamController<Object?>.broadcast(
          onListen: () => notificationListenCount++,
          sync: true,
        );
        final errors = StreamController<Object?>.broadcast(
          onListen: () => errorListenCount++,
          sync: true,
        );
        final pending = _pendingRequestForTransport(
          (_) async => NotificationStreams(
            notifications: notifications.stream,
            errors: errors.stream,
          ),
        );
        final source = CancellationTokenSource();
        final stream = await pending.subscribe(
          RpcSubscribeOptions(abortSignal: source.token),
        );

        source.cancel();
        await stream.drain<void>();

        expect(notificationListenCount, 0);
        expect(errorListenCount, 0);
        await notifications.close();
        await errors.close();
      },
    );

    test('subscribe rejects if aborted while transport is pending', () async {
      final transport = _DeferredSubscriptionsTransport();
      final pending = _pendingRequestForTransport(transport.transport);
      final source = CancellationTokenSource();
      final reason = StateError('cancelled before subscription');

      final future = pending.subscribe(
        RpcSubscribeOptions(abortSignal: source.token),
      );
      await Future<void>.delayed(Duration.zero);
      source.cancel(reason);

      await expectLater(future, throwsA(same(reason)));
    });

    test('reactiveStore surfaces an abort as an error state', () async {
      final transport = _DeferredSubscriptionsTransport();
      final pending = _pendingRequestForTransport(transport.transport);
      final source = CancellationTokenSource();

      final store = pending();
      final killableConnect = store.withSignal(source.token);
      killableConnect();
      await Future<void>.delayed(Duration.zero);
      source.cancel();

      await Future<void>.delayed(Duration.zero);
      expect(store.getState().status, ReactiveStreamState.error);
    });
  });

  group('RpcSubscriptions.request', () {
    test('throws SolanaError when API cannot build a plan', () {
      final subscriptions = RpcSubscriptions(
        api: _TestApi(),
        transport: (_) async => _emptyStreams(),
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
            'slotNotifications': const RpcSubscriptionsPlan<Object?>(
              execute: _planStreamsExecute,
              request: RpcSubscriptionsRequest(
                methodName: 'slotNotifications',
                params: [],
              ),
            ),
          },
        ),
        transport: (_) async => _emptyStreams(),
      );

      final pending = subscriptions.request('slotNotifications');
      expect(pending, isA<PendingRpcSubscriptionsRequest<Object?>>());
    });
  });

  group('typed subscription methods', () {
    test('accountNotifications builds method-specific params', () async {
      final captured = CapturingSubscriptionsTransport();
      final rpc = createSolanaRpcSubscriptionsFromTransport(captured.transport);
      await rpc
          .accountNotifications(
            testAccountAddressB,
            const AccountNotificationsConfig(
              encoding: AccountEncoding.base64,
              commitment: Commitment.confirmed,
            ),
          )
          .subscribe(
            RpcSubscribeOptions(abortSignal: CancellationTokenSource().token),
          );

      expect(captured.lastConfig.request.methodName, 'accountNotifications');
      expect(captured.lastConfig.request.params, [
        testAccountAddressB.value,
        {'encoding': 'base64', 'commitment': 'confirmed'},
      ]);
    });

    test('slotNotifications builds empty params', () async {
      final captured = CapturingSubscriptionsTransport();
      final rpc = createSolanaRpcSubscriptionsFromTransport(captured.transport);
      await rpc.slotNotifications().subscribe(
        RpcSubscribeOptions(abortSignal: CancellationTokenSource().token),
      );

      expect(captured.lastConfig.request.methodName, 'slotNotifications');
      expect(captured.lastConfig.request.params, isEmpty);
    });

    test('signatureNotifications builds method-specific params', () async {
      final captured = CapturingSubscriptionsTransport();
      final rpc = createSolanaRpcSubscriptionsFromTransport(captured.transport);
      await rpc
          .signatureNotifications(
            testSignatureValue,
            const SignatureNotificationsConfig(
              commitment: Commitment.confirmed,
              enableReceivedNotification: true,
            ),
          )
          .subscribe(
            RpcSubscribeOptions(abortSignal: CancellationTokenSource().token),
          );

      expect(captured.lastConfig.request.methodName, 'signatureNotifications');
      expect(captured.lastConfig.request.params, [
        testSignatureValue.value,
        {'commitment': 'confirmed', 'enableReceivedNotification': true},
      ]);
    });

    test('remaining typed helpers build method-specific params', () async {
      final captured = CapturingSubscriptionsTransport();
      final rpc = createSolanaRpcSubscriptionsFromTransport(captured.transport);
      final abortSignal = CancellationTokenSource().token;

      await rpc
          .blockNotifications(
            const BlockFilterMentionsAccountOrProgram(testAccountAddressA),
            const BlockNotificationsConfig(
              commitment: Commitment.finalized,
              encoding: TransactionEncoding.json,
              showRewards: false,
              transactionDetails: 'signatures',
            ),
          )
          .subscribe(RpcSubscribeOptions(abortSignal: abortSignal));
      await rpc
          .logsNotifications(
            const LogsFilterAllWithVotes(),
            const LogsNotificationsConfig(commitment: Commitment.confirmed),
          )
          .subscribe(RpcSubscribeOptions(abortSignal: abortSignal));
      await rpc
          .programNotifications(
            testProgramAddress,
            const ProgramNotificationsConfig(
              commitment: Commitment.processed,
              encoding: AccountEncoding.base64,
              filters: [
                {'dataSize': 165},
              ],
            ),
          )
          .subscribe(RpcSubscribeOptions(abortSignal: abortSignal));
      await rpc.rootNotifications().subscribe(
        RpcSubscribeOptions(abortSignal: abortSignal),
      );
      await rpc.slotsUpdatesNotifications().subscribe(
        RpcSubscribeOptions(abortSignal: abortSignal),
      );
      await rpc.voteNotifications().subscribe(
        RpcSubscribeOptions(abortSignal: abortSignal),
      );

      expect(
        captured.configs.map((config) => config.request.methodName).toList(),
        [
          'blockNotifications',
          'logsNotifications',
          'programNotifications',
          'rootNotifications',
          'slotsUpdatesNotifications',
          'voteNotifications',
        ],
      );
      expect(captured.configs[0].request.params, [
        {'mentionsAccountOrProgram': testAccountAddressA.value},
        {
          'commitment': 'finalized',
          'encoding': 'json',
          'showRewards': false,
          'transactionDetails': 'signatures',
        },
      ]);
      expect(captured.configs[1].request.params, [
        'allWithVotes',
        {'commitment': 'confirmed'},
      ]);
      expect(captured.configs[2].request.params, [
        testProgramAddress.value,
        {
          'commitment': 'processed',
          'encoding': 'base64',
          'filters': [
            {'dataSize': 165},
          ],
        },
      ]);
      expect(captured.configs[3].request.params, isEmpty);
      expect(captured.configs[4].request.params, isEmpty);
      expect(captured.configs[5].request.params, isEmpty);
    });
  });

  group('factory functions', () {
    test('createSubscriptionRpc preserves api and transport references', () {
      final api = _TestApi();
      Future<NotificationStreams> transport(
        RpcSubscriptionsTransportConfig _,
      ) async => _emptyStreams();
      final rpc = createSubscriptionRpc(
        RpcSubscriptionsConfig(api: api, transport: transport),
      );

      expect(rpc.api, same(api));
      expect(rpc.transport, same(transport));
    });

    test(
      'createSolanaRpcSubscriptionsFromTransport builds passthrough plans',
      () async {
        final captured = CapturingSubscriptionsTransport();
        final rpc = createSolanaRpcSubscriptionsFromTransport(
          captured.transport,
        );
        final pending = rpc.request('accountNotifications', ['pubkey', 'json']);
        await pending.subscribe(
          RpcSubscribeOptions(abortSignal: CancellationTokenSource().token),
        );

        expect(captured.lastConfig.request.methodName, 'accountNotifications');
        expect(captured.lastConfig.request.params, ['pubkey', 'json']);

        final channel = _MockChannel();
        final executeResult = await captured.lastConfig.execute(
          RpcSubscriptionsTransportExecuteConfig(
            channel: channel,
            signal: CancellationTokenSource().token,
          ),
        );
        expect(executeResult, same(channel.streams));
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

Future<NotificationStreams> _planStreamsExecute(
  RpcSubscriptionsTransportExecuteConfig _,
) async {
  final messages = StreamController<Object?>.broadcast(sync: true);
  final errors = StreamController<Object?>.broadcast(sync: true);
  return NotificationStreams(
    notifications: messages.stream,
    errors: errors.stream,
  );
}

NotificationStreams _emptyStreams() {
  final messages = StreamController<Object?>.broadcast(sync: true);
  final errors = StreamController<Object?>.broadcast(sync: true);
  return NotificationStreams(
    notifications: messages.stream,
    errors: errors.stream,
  );
}

PendingRpcSubscriptionsRequest<Object?> _pendingRequestForTransport(
  RpcSubscriptionsTransport transport,
) {
  return PendingRpcSubscriptionsRequest<Object?>(
    transport: transport,
    plan: const RpcSubscriptionsPlan<Object?>(
      execute: _planStreamsExecute,
      request: RpcSubscriptionsRequest(
        methodName: 'slotNotifications',
        params: [],
      ),
    ),
  );
}

class _DeferredSubscriptionsTransport {
  final _completer = Completer<NotificationStreams>();

  Future<NotificationStreams> transport(RpcSubscriptionsTransportConfig _) {
    return _completer.future;
  }
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
  _MockChannel()
    : _messagesController = StreamController<Object?>.broadcast(sync: true),
      _errorsController = StreamController<Object?>.broadcast(sync: true);

  final StreamController<Object?> _messagesController;
  final StreamController<Object?> _errorsController;

  @override
  late final NotificationStreams streams = NotificationStreams(
    notifications: _messagesController.stream,
    errors: _errorsController.stream,
  );

  @override
  Future<void> send(Object message) async {}
}
