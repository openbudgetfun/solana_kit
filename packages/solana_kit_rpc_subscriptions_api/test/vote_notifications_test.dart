import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:test/test.dart';

void main() {
  group('voteNotificationsParams', () {
    test('returns empty list', () {
      final params = voteNotificationsParams();
      expect(params, isEmpty);
    });
  });
}
