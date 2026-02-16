import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const testAddress = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  group('ProgramNotificationsConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = ProgramNotificationsConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = ProgramNotificationsConfig(
        commitment: Commitment.confirmed,
      );
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'confirmed');
    });

    test('toJson includes encoding when set', () {
      const config = ProgramNotificationsConfig(encoding: 'base64');
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['encoding'], 'base64');
    });

    test('toJson includes filters when set', () {
      const config = ProgramNotificationsConfig(
        filters: [
          {'dataSize': 165},
        ],
      );
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['filters'], [
        {'dataSize': 165},
      ]);
    });

    test('toJson includes all fields when all set', () {
      const config = ProgramNotificationsConfig(
        commitment: Commitment.finalized,
        encoding: 'jsonParsed',
        filters: [
          {'dataSize': 165},
        ],
      );
      final json = config.toJson();
      expect(json, hasLength(3));
      expect(json['commitment'], 'finalized');
      expect(json['encoding'], 'jsonParsed');
      expect(json['filters'], isA<List<Object>>());
    });
  });

  group('programNotificationsParams', () {
    test('returns list with only programId when no config', () {
      final params = programNotificationsParams(testAddress);
      expect(params, hasLength(1));
      expect(params[0], 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
    });

    test('returns list with programId and config when config provided', () {
      final params = programNotificationsParams(
        testAddress,
        const ProgramNotificationsConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(2));
      expect(params[0], 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'finalized');
    });
  });
}
