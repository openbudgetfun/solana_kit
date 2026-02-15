import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const testAddress = Address('11111111111111111111111111111111');

  group('GetBalanceConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetBalanceConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetBalanceConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'confirmed');
    });

    test('toJson includes minContextSlot when set', () {
      final config = GetBalanceConfig(minContextSlot: BigInt.from(42));
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['minContextSlot'], BigInt.from(42));
    });

    test('toJson includes all fields when all set', () {
      final config = GetBalanceConfig(
        commitment: Commitment.processed,
        minContextSlot: BigInt.from(100),
      );
      final json = config.toJson();
      expect(json, hasLength(2));
      expect(json['commitment'], 'processed');
      expect(json['minContextSlot'], BigInt.from(100));
    });
  });

  group('getBalanceParams', () {
    test('returns list with only address when no config', () {
      final params = getBalanceParams(testAddress);
      expect(params, hasLength(1));
      expect(params[0], '11111111111111111111111111111111');
    });

    test('returns list with address and config when config provided', () {
      final params = getBalanceParams(
        testAddress,
        const GetBalanceConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(2));
      expect(params[0], '11111111111111111111111111111111');
      expect(params[1], isA<Map<String, Object?>>());
    });
  });
}
