import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetSlotLeaderConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetSlotLeaderConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetSlotLeaderConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'confirmed');
    });

    test('toJson includes minContextSlot when set', () {
      final config = GetSlotLeaderConfig(minContextSlot: BigInt.from(22));
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['minContextSlot'], BigInt.from(22));
    });

    test('toJson includes all fields when all set', () {
      final config = GetSlotLeaderConfig(
        commitment: Commitment.finalized,
        minContextSlot: BigInt.from(99),
      );
      final json = config.toJson();
      expect(json, hasLength(2));
      expect(json['commitment'], 'finalized');
      expect(json['minContextSlot'], BigInt.from(99));
    });
  });

  group('getSlotLeaderParams', () {
    test('returns empty list when no config', () {
      final params = getSlotLeaderParams();
      expect(params, isEmpty);
    });

    test('returns list with config map when config provided', () {
      final params = getSlotLeaderParams(
        const GetSlotLeaderConfig(commitment: Commitment.confirmed),
      );
      expect(params, hasLength(1));
      expect(params[0], isA<Map<String, Object?>>());
      final config = params[0]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
    });
  });
}
