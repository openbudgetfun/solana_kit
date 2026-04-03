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
    test('subscribe wires plan request/abort signal into transport', () async {
      final captured = CapturingSubscriptionsTransport();
      final plan = RpcSubscriptionsPlan<Object?>(
        execute: (_) async => createDataPublisher(),
        request: RpcSubscriptionsRequest(
          methodName: 'accountNotifications',
          params: [testAccountAddressB.value],
        ),
      );

      final pending = PendingRpcSubscriptionsRequest<Object?>(
        transport: captured.transport,
        plan: plan,
      );
      final abortController = AbortController();
      final stream = await pending.subscribe(
        RpcSubscribeOptions(abortSignal: abortController.signal),
      );

      expect(captured.lastConfig.request.methodName, 'accountNotifications');
      expect(captured.lastConfig.request.params, [testAccountAddressB.value]);
      expect(captured.lastConfig.signal, same(abortController.signal));

      final firstEvent = stream.first;
      captured.publisher.publish('notification', {'slot': 123});
      expect(await firstEvent, {'slot': 123});
    });

    test('subscribe forwards error events from the data publisher', () async {
      final captured = CapturingSubscriptionsTransport();
      final pending = PendingRpcSubscriptionsRequest<Object?>(
        transport: captured.transport,
        plan: const RpcSubscriptionsPlan<Object?>(
          execute: _planPublisherExecute,
          request: RpcSubscriptionsRequest(
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

      captured.publisher.publish('error', 'boom');
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
            'slotNotifications': const RpcSubscriptionsPlan<Object?>(
              execute: _planPublisherExecute,
              request: RpcSubscriptionsRequest(
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
            RpcSubscribeOptions(abortSignal: AbortController().signal),
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
        RpcSubscribeOptions(abortSignal: AbortController().signal),
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
            RpcSubscribeOptions(abortSignal: AbortController().signal),
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
      final abortSignal = AbortController().signal;

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
        final captured = CapturingSubscriptionsTransport();
        final rpc = createSolanaRpcSubscriptionsFromTransport(
          captured.transport,
        );
        final pending = rpc.request('accountNotifications', ['pubkey', 'json']);
        await pending.subscribe(
          RpcSubscribeOptions(abortSignal: AbortController().signal),
        );

        expect(captured.lastConfig.request.methodName, 'accountNotifications');
        expect(captured.lastConfig.request.params, ['pubkey', 'json']);

        final channel = _MockChannel();
        final executeResult = await captured.lastConfig.execute(
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

Future<DataPublisher> _planPublisherExecute(
  RpcSubscriptionsTransportExecuteConfig _,
) async => createDataPublisher();

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
