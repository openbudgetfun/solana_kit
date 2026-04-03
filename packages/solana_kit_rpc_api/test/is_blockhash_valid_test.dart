import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const testBlockhash = Blockhash('11111111111111111111111111111111');

  group('IsBlockhashValidConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = IsBlockhashValidConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = IsBlockhashValidConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'confirmed');
    });

    test('toJson includes minContextSlot when set', () {
      final config = IsBlockhashValidConfig(minContextSlot: BigInt.from(9));
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['minContextSlot'], BigInt.from(9));
    });

    test('toJson includes all fields when all set', () {
      final config = IsBlockhashValidConfig(
        commitment: Commitment.finalized,
        minContextSlot: BigInt.from(100),
      );
      final json = config.toJson();
      expect(json, hasLength(2));
      expect(json['commitment'], 'finalized');
      expect(json['minContextSlot'], BigInt.from(100));
    });
  });

  group('isBlockhashValidParams', () {
    test('returns list with only blockhash when no config', () {
      final params = isBlockhashValidParams(testBlockhash);
      expect(params, hasLength(1));
      expect(params[0], testBlockhash.value);
    });

    test('returns list with blockhash and config when config provided', () {
      final params = isBlockhashValidParams(
        testBlockhash,
        const IsBlockhashValidConfig(commitment: Commitment.confirmed),
      );
      expect(params, hasLength(2));
      expect(params[0], testBlockhash.value);
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
    });
  });
}
