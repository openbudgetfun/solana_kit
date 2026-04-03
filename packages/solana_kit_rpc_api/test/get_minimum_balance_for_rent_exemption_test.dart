import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetMinimumBalanceForRentExemptionConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetMinimumBalanceForRentExemptionConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetMinimumBalanceForRentExemptionConfig(
        commitment: Commitment.finalized,
      );
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'finalized');
    });
  });

  group('getMinimumBalanceForRentExemptionParams', () {
    test('returns list with only size when no config', () {
      final params =
          getMinimumBalanceForRentExemptionParams(BigInt.from(165));
      expect(params, hasLength(1));
      expect(params[0], BigInt.from(165));
    });

    test('returns list with size and config when config provided', () {
      final params = getMinimumBalanceForRentExemptionParams(
        BigInt.from(200),
        const GetMinimumBalanceForRentExemptionConfig(
          commitment: Commitment.confirmed,
        ),
      );
      expect(params, hasLength(2));
      expect(params[0], BigInt.from(200));
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
    });
  });
}
