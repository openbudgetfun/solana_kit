import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  group('account fixtures', () {
    test('build base64 and jsonParsed account payloads', () {
      final base64 = base64RpcAccountFixture();
      final jsonParsed = jsonParsedRpcAccountFixture();

      expect(base64['data'], ['somedata', 'base64']);
      expect(base64['owner'], testOwnerAddress.value);
      expect(
        (jsonParsed['data'] as Map<String, dynamic>)['program'],
        'splToken',
      );
      expect(
        ((jsonParsed['data'] as Map<String, dynamic>)['parsed']
            as Map<String, dynamic>)['type'],
        'token',
      );
    });

    test(
      'createAccountsFixtureRpc returns single and multi-account responses',
      () async {
        final rpc = createAccountsFixtureRpc({
          testAccountAddressA: base64RpcAccountFixture(),
        });

        final single =
            (await rpc.request('getAccountInfo', [
                  testAccountAddressA.value,
                ]).send())!
                as Map<String, dynamic>;
        final multi =
            (await rpc.request('getMultipleAccounts', [
                  [testAccountAddressA.value, testAccountAddressB.value],
                ]).send())!
                as Map<String, dynamic>;

        expect(single['value'], isNotNull);
        expect(
          (single['context'] as Map<String, dynamic>)['slot'],
          BigInt.zero,
        );
        expect(multi['value'], [isNotNull, isNull]);
      },
    );
  });

  group('transaction fixtures', () {
    test(
      'createTransactionFixture and nonZeroSignatureBytes work together',
      () {
        final transaction = createTransactionFixture(
          signature: nonZeroSignatureBytes(),
        );

        expect(transaction, isFullySignedTransactionMatcher);
        expect(transaction.signatures.keys.single, testFeePayerAddress);
      },
    );
  });

  group('subscription fixtures', () {
    test(
      'CapturingSubscriptionsTransport records configs and returns publisher',
      () async {
        final transport = CapturingSubscriptionsTransport();
        final config = RpcSubscriptionsTransportConfig(
          execute: (_) async => transport.publisher,
          request: const RpcSubscriptionsRequest(
            methodName: 'slotNotifications',
            params: [],
          ),
          signal: AbortController().signal,
        );

        final publisher = await transport.transport(config);

        expect(publisher, same(transport.publisher));
        expect(transport.lastConfig.request.methodName, 'slotNotifications');
      },
    );
  });

  group('Helius payload fixtures', () {
    test('build acknowledgement and notification payloads', () {
      expect(heliusSubscriptionAckFixture(id: 1, subscription: 99), {
        'jsonrpc': '2.0',
        'id': 1,
        'result': 99,
      });
      expect(
        heliusNotificationFixture(
          method: 'accountNotification',
          subscription: 99,
          result: {'value': 'ok'},
        ),
        {
          'jsonrpc': '2.0',
          'method': 'accountNotification',
          'params': {
            'subscription': 99,
            'result': {'value': 'ok'},
          },
        },
      );
    });
  });
}
