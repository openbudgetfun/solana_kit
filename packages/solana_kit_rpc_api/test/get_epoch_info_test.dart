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

  group('GetEpochInfoConfig equality', () {
    test('supports equality, hashCode, and toString', () {
      final a = GetEpochInfoConfig(
        commitment: Commitment.finalized,
        minContextSlot: BigInt.from(12),
      );
      final b = GetEpochInfoConfig(
        commitment: Commitment.finalized,
        minContextSlot: BigInt.from(12),
      );
      final c = GetEpochInfoConfig(minContextSlot: BigInt.from(13));

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a.toString(), contains('minContextSlot: 12'));
    });
  });

  group('EpochInfo', () {
    test('supports equality, hashCode, and toString', () {
      final a = EpochInfo(
        absoluteSlot: BigInt.one,
        blockHeight: BigInt.from(2),
        epoch: BigInt.from(3),
        slotIndex: BigInt.from(4),
        slotsInEpoch: BigInt.from(5),
        transactionCount: BigInt.from(6),
      );
      final b = EpochInfo(
        absoluteSlot: BigInt.one,
        blockHeight: BigInt.from(2),
        epoch: BigInt.from(3),
        slotIndex: BigInt.from(4),
        slotsInEpoch: BigInt.from(5),
        transactionCount: BigInt.from(6),
      );
      final c = EpochInfo(
        absoluteSlot: BigInt.one,
        blockHeight: BigInt.from(2),
        epoch: BigInt.from(3),
        slotIndex: BigInt.from(4),
        slotsInEpoch: BigInt.from(5),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a.toString(), contains('transactionCount: 6'));
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
