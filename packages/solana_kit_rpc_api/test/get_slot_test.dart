import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetSlotConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetSlotConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetSlotConfig(commitment: Commitment.processed);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'processed');
    });

    test('toJson includes minContextSlot when set', () {
      final config = GetSlotConfig(minContextSlot: BigInt.from(8));
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['minContextSlot'], BigInt.from(8));
    });

    test('toJson includes all fields when all set', () {
      final config = GetSlotConfig(
        commitment: Commitment.confirmed,
        minContextSlot: BigInt.from(50),
      );
      final json = config.toJson();
      expect(json, hasLength(2));
      expect(json['commitment'], 'confirmed');
      expect(json['minContextSlot'], BigInt.from(50));
    });
  });

  group('getSlotParams', () {
    test('returns empty list when no config', () {
      final params = getSlotParams();
      expect(params, isEmpty);
    });

    test('returns list with config map when config provided', () {
      final params =
          getSlotParams(const GetSlotConfig(commitment: Commitment.finalized));
      expect(params, hasLength(1));
      expect(params[0], isA<Map<String, Object?>>());
      final config = params[0]! as Map<String, Object?>;
      expect(config['commitment'], 'finalized');
    });
  });
}
