import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:test/test.dart';

void main() {
  group('getBlockTimeParams', () {
    test('returns list containing the block number', () {
      final params = getBlockTimeParams(BigInt.from(999));
      expect(params, hasLength(1));
      expect(params[0], BigInt.from(999));
    });

    test('block number is preserved as BigInt', () {
      final slot = BigInt.from(42000000);
      final params = getBlockTimeParams(slot);
      expect(params[0], slot);
    });
  });
}
