import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetEpochInfoConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetEpochInfoConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetEpochInfoConfig(commitment: Commitment.finalized);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'finalized');
    });

    test('toJson includes minContextSlot when set', () {
      final config = GetEpochInfoConfig(minContextSlot: BigInt.from(50));
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['minContextSlot'], BigInt.from(50));
    });

    test('toJson includes all fields when all set', () {
      final config = GetEpochInfoConfig(
        commitment: Commitment.confirmed,
        minContextSlot: BigInt.from(200),
      );
      final json = config.toJson();
      expect(json, hasLength(2));
      expect(json['commitment'], 'confirmed');
      expect(json['minContextSlot'], BigInt.from(200));
    });
  });

  group('getEpochInfoParams', () {
    test('returns empty list when no config', () {
      final params = getEpochInfoParams();
      expect(params, isEmpty);
    });

    test('returns list with config map when config provided', () {
      final params = getEpochInfoParams(
        const GetEpochInfoConfig(commitment: Commitment.confirmed),
      );
      expect(params, hasLength(1));
      expect(params[0], isA<Map<String, Object?>>());
      final config = params[0]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
    });
  });
}
