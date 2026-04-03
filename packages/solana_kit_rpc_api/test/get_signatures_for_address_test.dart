import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const testAddress = Address('11111111111111111111111111111111');
  const sigA = Signature(
    '1111111111111111111111111111111111111111111111111111111111111111',
  );
  const sigB = Signature(
    '2222222222222222222222222222222222222222222222222222222222222222',
  );

  group('GetSignaturesForAddressConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetSignaturesForAddressConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes before when set', () {
      const config = GetSignaturesForAddressConfig(before: sigA);
      final json = config.toJson();
      expect(json['before'], sigA.value);
    });

    test('toJson includes commitment when set', () {
      const config = GetSignaturesForAddressConfig(
        commitment: Commitment.finalized,
      );
      final json = config.toJson();
      expect(json['commitment'], 'finalized');
    });

    test('toJson includes limit when set', () {
      const config = GetSignaturesForAddressConfig(limit: 10);
      final json = config.toJson();
      expect(json['limit'], 10);
    });

    test('toJson includes minContextSlot when set', () {
      final config =
          GetSignaturesForAddressConfig(minContextSlot: BigInt.from(55));
      final json = config.toJson();
      expect(json['minContextSlot'], BigInt.from(55));
    });

    test('toJson includes until when set', () {
      const config = GetSignaturesForAddressConfig(until: sigB);
      final json = config.toJson();
      expect(json['until'], sigB.value);
    });

    test('toJson includes all fields when all set', () {
      final config = GetSignaturesForAddressConfig(
        before: sigA,
        commitment: Commitment.finalized,
        limit: 10,
        minContextSlot: BigInt.from(55),
        until: sigB,
      );
      final json = config.toJson();
      expect(json, hasLength(5));
      expect(json['before'], sigA.value);
      expect(json['commitment'], 'finalized');
      expect(json['limit'], 10);
      expect(json['minContextSlot'], BigInt.from(55));
      expect(json['until'], sigB.value);
    });
  });

  group('getSignaturesForAddressParams', () {
    test('returns list with only address when no config', () {
      final params = getSignaturesForAddressParams(testAddress);
      expect(params, hasLength(1));
      expect(params[0], '11111111111111111111111111111111');
    });

    test('returns list with address and config when config provided', () {
      final params = getSignaturesForAddressParams(
        testAddress,
        const GetSignaturesForAddressConfig(limit: 5),
      );
      expect(params, hasLength(2));
      expect(params[0], '11111111111111111111111111111111');
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['limit'], 5);
    });
  });
}
