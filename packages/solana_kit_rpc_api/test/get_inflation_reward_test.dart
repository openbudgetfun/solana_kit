import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const addressA = Address('11111111111111111111111111111111');
  const addressB = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  group('GetInflationRewardConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetInflationRewardConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config =
          GetInflationRewardConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json['commitment'], 'confirmed');
    });

    test('toJson includes epoch when set', () {
      final config = GetInflationRewardConfig(epoch: BigInt.from(5));
      final json = config.toJson();
      expect(json['epoch'], BigInt.from(5));
    });

    test('toJson includes minContextSlot when set', () {
      final config =
          GetInflationRewardConfig(minContextSlot: BigInt.from(300));
      final json = config.toJson();
      expect(json['minContextSlot'], BigInt.from(300));
    });

    test('toJson includes all fields when all set', () {
      final config = GetInflationRewardConfig(
        commitment: Commitment.finalized,
        epoch: BigInt.from(3),
        minContextSlot: BigInt.from(4),
      );
      final json = config.toJson();
      expect(json, hasLength(3));
      expect(json['commitment'], 'finalized');
      expect(json['epoch'], BigInt.from(3));
      expect(json['minContextSlot'], BigInt.from(4));
    });
  });

  group('getInflationRewardParams', () {
    test('returns list with address array when no config', () {
      final params = getInflationRewardParams([addressA, addressB]);
      expect(params, hasLength(1));
      expect(
        params[0],
        [addressA.value, addressB.value],
      );
    });

    test('returns list with address array and config when config provided', () {
      final params = getInflationRewardParams(
        [addressA],
        const GetInflationRewardConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(2));
      expect(params[0], [addressA.value]);
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'finalized');
    });

    test('handles empty address list', () {
      final params = getInflationRewardParams([]);
      expect(params, hasLength(1));
      expect(params[0], isEmpty);
    });
  });
}
