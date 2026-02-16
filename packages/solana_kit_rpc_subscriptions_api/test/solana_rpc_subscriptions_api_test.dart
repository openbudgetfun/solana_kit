import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:test/test.dart';

void main() {
  group('SolanaRpcSubscriptionsApi', () {
    group('solanaRpcSubscriptionsMethodsStable', () {
      test('contains all expected stable methods', () {
        expect(
          solanaRpcSubscriptionsMethodsStable,
          containsAll(<String>[
            'accountSubscribe',
            'logsSubscribe',
            'programSubscribe',
            'rootSubscribe',
            'signatureSubscribe',
            'slotSubscribe',
          ]),
        );
      });

      test('does not contain unstable methods', () {
        expect(
          solanaRpcSubscriptionsMethodsStable,
          isNot(contains('blockSubscribe')),
        );
        expect(
          solanaRpcSubscriptionsMethodsStable,
          isNot(contains('slotsUpdatesSubscribe')),
        );
        expect(
          solanaRpcSubscriptionsMethodsStable,
          isNot(contains('voteSubscribe')),
        );
      });

      test('has 6 methods', () {
        expect(solanaRpcSubscriptionsMethodsStable, hasLength(6));
      });
    });

    group('solanaRpcSubscriptionsMethodsUnstable', () {
      test('includes all stable methods', () {
        for (final method in solanaRpcSubscriptionsMethodsStable) {
          expect(
            solanaRpcSubscriptionsMethodsUnstable,
            contains(method),
            reason: 'Unstable methods should include $method',
          );
        }
      });

      test('includes unstable methods', () {
        expect(
          solanaRpcSubscriptionsMethodsUnstable,
          contains('blockSubscribe'),
        );
        expect(
          solanaRpcSubscriptionsMethodsUnstable,
          contains('slotsUpdatesSubscribe'),
        );
        expect(
          solanaRpcSubscriptionsMethodsUnstable,
          contains('voteSubscribe'),
        );
      });

      test('has 9 methods', () {
        expect(solanaRpcSubscriptionsMethodsUnstable, hasLength(9));
      });
    });

    group('solanaRpcSubscriptionsNotificationsStable', () {
      test('contains all expected stable notification names', () {
        expect(
          solanaRpcSubscriptionsNotificationsStable,
          containsAll(<String>[
            'accountNotifications',
            'logsNotifications',
            'programNotifications',
            'rootNotifications',
            'signatureNotifications',
            'slotNotifications',
          ]),
        );
      });

      test('has 6 notification names', () {
        expect(solanaRpcSubscriptionsNotificationsStable, hasLength(6));
      });
    });

    group('solanaRpcSubscriptionsNotificationsUnstable', () {
      test('includes unstable notification names', () {
        expect(
          solanaRpcSubscriptionsNotificationsUnstable,
          contains('blockNotifications'),
        );
        expect(
          solanaRpcSubscriptionsNotificationsUnstable,
          contains('slotsUpdatesNotifications'),
        );
        expect(
          solanaRpcSubscriptionsNotificationsUnstable,
          contains('voteNotifications'),
        );
      });

      test('has 9 notification names', () {
        expect(solanaRpcSubscriptionsNotificationsUnstable, hasLength(9));
      });
    });

    group('helper functions', () {
      test('isSolanaRpcSubscriptionMethodStable returns true for stable', () {
        expect(isSolanaRpcSubscriptionMethodStable('accountSubscribe'), isTrue);
        expect(isSolanaRpcSubscriptionMethodStable('slotSubscribe'), isTrue);
      });

      test(
        'isSolanaRpcSubscriptionMethodStable returns false for unstable',
        () {
          expect(
            isSolanaRpcSubscriptionMethodStable('blockSubscribe'),
            isFalse,
          );
          expect(isSolanaRpcSubscriptionMethodStable('voteSubscribe'), isFalse);
        },
      );

      test('isSolanaRpcSubscriptionMethod returns true for all methods', () {
        expect(isSolanaRpcSubscriptionMethod('accountSubscribe'), isTrue);
        expect(isSolanaRpcSubscriptionMethod('blockSubscribe'), isTrue);
        expect(isSolanaRpcSubscriptionMethod('voteSubscribe'), isTrue);
      });

      test('isSolanaRpcSubscriptionMethod returns false for unknown', () {
        expect(isSolanaRpcSubscriptionMethod('unknownSubscribe'), isFalse);
      });

      test('notificationNameToSubscribeMethod transforms correctly', () {
        expect(
          notificationNameToSubscribeMethod('accountNotifications'),
          'accountSubscribe',
        );
        expect(
          notificationNameToSubscribeMethod('signatureNotifications'),
          'signatureSubscribe',
        );
        expect(
          notificationNameToSubscribeMethod('slotNotifications'),
          'slotSubscribe',
        );
        expect(
          notificationNameToSubscribeMethod('blockNotifications'),
          'blockSubscribe',
        );
        expect(
          notificationNameToSubscribeMethod('slotsUpdatesNotifications'),
          'slotsUpdatesSubscribe',
        );
      });

      test('notificationNameToUnsubscribeMethod transforms correctly', () {
        expect(
          notificationNameToUnsubscribeMethod('accountNotifications'),
          'accountUnsubscribe',
        );
        expect(
          notificationNameToUnsubscribeMethod('signatureNotifications'),
          'signatureUnsubscribe',
        );
        expect(
          notificationNameToUnsubscribeMethod('slotNotifications'),
          'slotUnsubscribe',
        );
        expect(
          notificationNameToUnsubscribeMethod('blockNotifications'),
          'blockUnsubscribe',
        );
        expect(
          notificationNameToUnsubscribeMethod('slotsUpdatesNotifications'),
          'slotsUpdatesUnsubscribe',
        );
      });

      test('every notification name maps to a subscribe method in the '
          'methods list', () {
        for (final name in solanaRpcSubscriptionsNotificationsUnstable) {
          final subscribeMethod = notificationNameToSubscribeMethod(name);
          expect(
            solanaRpcSubscriptionsMethodsUnstable,
            contains(subscribeMethod),
            reason:
                '$name should map to $subscribeMethod which should be in '
                'the methods list',
          );
        }
      });
    });
  });
}
