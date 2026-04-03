import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetFeeForMessageConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetFeeForMessageConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetFeeForMessageConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'confirmed');
    });

    test('toJson includes minContextSlot when set', () {
      final config =
          GetFeeForMessageConfig(minContextSlot: BigInt.from(42));
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['minContextSlot'], BigInt.from(42));
    });

    test('toJson includes all fields when all set', () {
      final config = GetFeeForMessageConfig(
        commitment: Commitment.finalized,
        minContextSlot: BigInt.from(8),
      );
      final json = config.toJson();
      expect(json, hasLength(2));
      expect(json['commitment'], 'finalized');
      expect(json['minContextSlot'], BigInt.from(8));
    });
  });

  group('getFeeForMessageParams', () {
    test('returns list with only message when no config', () {
      final params = getFeeForMessageParams('AQID');
      expect(params, hasLength(1));
      expect(params[0], 'AQID');
    });

    test('returns list with message and config when config provided', () {
      final params = getFeeForMessageParams(
        'AQID',
        const GetFeeForMessageConfig(commitment: Commitment.confirmed),
      );
      expect(params, hasLength(2));
      expect(params[0], 'AQID');
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
    });
  });
}
