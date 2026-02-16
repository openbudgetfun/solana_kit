import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const testAddress = Address('11111111111111111111111111111111');

  group('AccountNotificationsConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = AccountNotificationsConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = AccountNotificationsConfig(
        commitment: Commitment.finalized,
      );
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'finalized');
    });

    test('toJson includes encoding when set', () {
      const config = AccountNotificationsConfig(encoding: 'base64');
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['encoding'], 'base64');
    });

    test('toJson includes all fields when all set', () {
      const config = AccountNotificationsConfig(
        commitment: Commitment.confirmed,
        encoding: 'jsonParsed',
      );
      final json = config.toJson();
      expect(json, hasLength(2));
      expect(json['commitment'], 'confirmed');
      expect(json['encoding'], 'jsonParsed');
    });
  });

  group('accountNotificationsParams', () {
    test('returns list with only address when no config', () {
      final params = accountNotificationsParams(testAddress);
      expect(params, hasLength(1));
      expect(params[0], '11111111111111111111111111111111');
    });

    test('returns list with address and config when config provided', () {
      final params = accountNotificationsParams(
        testAddress,
        const AccountNotificationsConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(2));
      expect(params[0], '11111111111111111111111111111111');
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'finalized');
    });

    test('address value is the string representation', () {
      const addr = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      final params = accountNotificationsParams(addr);
      expect(params[0], 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
    });
  });
}
