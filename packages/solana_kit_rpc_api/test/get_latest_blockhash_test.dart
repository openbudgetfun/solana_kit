import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetLatestBlockhashConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetLatestBlockhashConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config =
          GetLatestBlockhashConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'confirmed');
    });

    test('toJson includes minContextSlot when set', () {
      final config =
          GetLatestBlockhashConfig(minContextSlot: BigInt.from(33));
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['minContextSlot'], BigInt.from(33));
    });

    test('toJson includes all fields when all set', () {
      final config = GetLatestBlockhashConfig(
        commitment: Commitment.processed,
        minContextSlot: BigInt.from(33),
      );
      final json = config.toJson();
      expect(json, hasLength(2));
      expect(json['commitment'], 'processed');
      expect(json['minContextSlot'], BigInt.from(33));
    });
  });

  group('getLatestBlockhashParams', () {
    test('returns empty list when no config', () {
      final params = getLatestBlockhashParams();
      expect(params, isEmpty);
    });

    test('returns list with config map when config provided', () {
      final params = getLatestBlockhashParams(
        const GetLatestBlockhashConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(1));
      expect(params[0], isA<Map<String, Object?>>());
      final config = params[0]! as Map<String, Object?>;
      expect(config['commitment'], 'finalized');
    });
  });
}
