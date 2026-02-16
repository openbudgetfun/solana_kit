import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:test/test.dart';

void main() {
  group('rootNotificationsParams', () {
    test('returns empty list', () {
      final params = rootNotificationsParams();
      expect(params, isEmpty);
    });
  });
}
