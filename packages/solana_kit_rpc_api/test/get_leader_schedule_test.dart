import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const testAddress = Address('11111111111111111111111111111111');

  group('GetLeaderScheduleConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetLeaderScheduleConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config =
          GetLeaderScheduleConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json['commitment'], 'confirmed');
    });

    test('toJson includes identity when set', () {
      const config = GetLeaderScheduleConfig(identity: testAddress);
      final json = config.toJson();
      expect(json['identity'], '11111111111111111111111111111111');
    });

    test('toJson includes all fields when all set', () {
      const config = GetLeaderScheduleConfig(
        commitment: Commitment.finalized,
        identity: testAddress,
      );
      final json = config.toJson();
      expect(json, hasLength(2));
      expect(json['commitment'], 'finalized');
      expect(json['identity'], '11111111111111111111111111111111');
    });
  });

  group('getLeaderScheduleParams', () {
    test('returns [null] when no arguments', () {
      final params = getLeaderScheduleParams();
      expect(params, hasLength(1));
      expect(params[0], isNull);
    });

    test('returns [slot] when only slot provided', () {
      final params = getLeaderScheduleParams(BigInt.from(9));
      expect(params, hasLength(1));
      expect(params[0], BigInt.from(9));
    });

    test('returns [slot, config] when both provided', () {
      final params = getLeaderScheduleParams(
        BigInt.from(5),
        const GetLeaderScheduleConfig(commitment: Commitment.confirmed),
      );
      expect(params, hasLength(2));
      expect(params[0], BigInt.from(5));
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
    });

    test('returns [null, config] when slot is null but config provided', () {
      final params = getLeaderScheduleParams(
        null,
        const GetLeaderScheduleConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(2));
      expect(params[0], isNull);
      expect(params[1], isA<Map<String, Object?>>());
    });
  });
}
