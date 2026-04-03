import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:test/test.dart';

void main() {
  group('getSlotLeadersParams', () {
    test('returns list with start slot and limit', () {
      final params = getSlotLeadersParams(BigInt.from(100), 4);
      expect(params, hasLength(2));
      expect(params[0], BigInt.from(100));
      expect(params[1], 4);
    });

    test('start slot is preserved as BigInt', () {
      final slot = BigInt.from(500000);
      final params = getSlotLeadersParams(slot, 10);
      expect(params[0], slot);
    });

    test('limit is preserved as int', () {
      final params = getSlotLeadersParams(BigInt.from(1), 20);
      expect(params[1], 20);
    });
  });
}
