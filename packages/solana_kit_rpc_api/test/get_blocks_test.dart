import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetBlocksConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetBlocksConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetBlocksConfig(commitment: Commitment.finalized);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'finalized');
    });
  });

  group('getBlocksParams', () {
    test('returns list with only start slot when no end slot or config', () {
      final params = getBlocksParams(BigInt.from(1));
      expect(params, hasLength(1));
      expect(params[0], BigInt.from(1));
    });

    test('returns list with start and end slot when end slot provided', () {
      final params = getBlocksParams(BigInt.from(1), BigInt.from(5));
      expect(params, hasLength(2));
      expect(params[0], BigInt.from(1));
      expect(params[1], BigInt.from(5));
    });

    test('returns list with start slot and config when only config provided', () {
      final params = getBlocksParams(
        BigInt.from(10),
        null,
        const GetBlocksConfig(commitment: Commitment.confirmed),
      );
      expect(params, hasLength(2));
      expect(params[0], BigInt.from(10));
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
    });

    test('returns all three elements when all args provided', () {
      final params = getBlocksParams(
        BigInt.from(1),
        BigInt.from(9),
        const GetBlocksConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(3));
      expect(params[0], BigInt.from(1));
      expect(params[1], BigInt.from(9));
      expect(params[2], isA<Map<String, Object?>>());
    });
  });
}
