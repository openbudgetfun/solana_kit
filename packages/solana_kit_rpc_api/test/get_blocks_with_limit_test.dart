import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetBlocksWithLimitConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetBlocksWithLimitConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config =
          GetBlocksWithLimitConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'confirmed');
    });
  });

  group('getBlocksWithLimitParams', () {
    test('returns list with start slot and limit when no config', () {
      final params = getBlocksWithLimitParams(BigInt.from(10), 5);
      expect(params, hasLength(2));
      expect(params[0], BigInt.from(10));
      expect(params[1], 5);
    });

    test('returns list with all three elements when config provided', () {
      final params = getBlocksWithLimitParams(
        BigInt.from(20),
        10,
        const GetBlocksWithLimitConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(3));
      expect(params[0], BigInt.from(20));
      expect(params[1], 10);
      expect(params[2], isA<Map<String, Object?>>());
      final config = params[2]! as Map<String, Object?>;
      expect(config['commitment'], 'finalized');
    });
  });
}
