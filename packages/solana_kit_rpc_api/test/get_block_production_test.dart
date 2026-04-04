import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const testAddress = Address('11111111111111111111111111111111');

  group('SlotRange', () {
    test('toJson includes only firstSlot when lastSlot omitted', () {
      final range = SlotRange(firstSlot: BigInt.from(10));
      final json = range.toJson();
      expect(json, hasLength(1));
      expect(json['firstSlot'], BigInt.from(10));
    });

    test('toJson includes both slots when lastSlot provided', () {
      final range = SlotRange(
        firstSlot: BigInt.from(10),
        lastSlot: BigInt.from(20),
      );
      final json = range.toJson();
      expect(json, hasLength(2));
      expect(json['firstSlot'], BigInt.from(10));
      expect(json['lastSlot'], BigInt.from(20));
    });
  });

  group('GetBlockProductionConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetBlockProductionConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetBlockProductionConfig(commitment: Commitment.finalized);
      final json = config.toJson();
      expect(json['commitment'], 'finalized');
    });

    test('toJson includes identity when set', () {
      const config = GetBlockProductionConfig(identity: testAddress);
      final json = config.toJson();
      expect(json['identity'], '11111111111111111111111111111111');
    });

    test('toJson includes range when set', () {
      final config = GetBlockProductionConfig(
        range: SlotRange(firstSlot: BigInt.from(5), lastSlot: BigInt.from(10)),
      );
      final json = config.toJson();
      expect(json['range'], {
        'firstSlot': BigInt.from(5),
        'lastSlot': BigInt.from(10),
      });
    });

    test('toJson includes all fields when all set', () {
      final config = GetBlockProductionConfig(
        commitment: Commitment.confirmed,
        identity: testAddress,
        range: SlotRange(firstSlot: BigInt.from(1)),
      );
      final json = config.toJson();
      expect(json, hasLength(3));
      expect(json['commitment'], 'confirmed');
      expect(json['identity'], '11111111111111111111111111111111');
      expect(json['range'], {'firstSlot': BigInt.from(1)});
    });
  });

  group('equality and toString', () {
    test('SlotRange supports equality, hashCode, and toString', () {
      final a = SlotRange(
        firstSlot: BigInt.from(10),
        lastSlot: BigInt.from(20),
      );
      final b = SlotRange(
        firstSlot: BigInt.from(10),
        lastSlot: BigInt.from(20),
      );
      final c = SlotRange(firstSlot: BigInt.from(10));

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a.toString(), contains('lastSlot: 20'));
    });

    test('GetBlockProductionConfig supports equality and toString', () {
      final a = GetBlockProductionConfig(
        commitment: Commitment.confirmed,
        identity: testAddress,
        range: SlotRange(firstSlot: BigInt.from(1)),
      );
      final b = GetBlockProductionConfig(
        commitment: Commitment.confirmed,
        identity: testAddress,
        range: SlotRange(firstSlot: BigInt.from(1)),
      );
      const c = GetBlockProductionConfig(identity: testAddress);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a.toString(), contains('identity: $testAddress'));
    });
  });

  group('getBlockProductionParams', () {
    test('returns empty list when no config', () {
      final params = getBlockProductionParams();
      expect(params, isEmpty);
    });

    test('returns list with config map when config provided', () {
      final params = getBlockProductionParams(
        const GetBlockProductionConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(1));
      expect(params[0], isA<Map<String, Object?>>());
      final config = params[0]! as Map<String, Object?>;
      expect(config['commitment'], 'finalized');
    });
  });
}
