import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:test/test.dart';

void main() {
  group('getBlockCommitmentParams', () {
    test('returns list containing the slot', () {
      final params = getBlockCommitmentParams(BigInt.from(12345));
      expect(params, hasLength(1));
      expect(params[0], BigInt.from(12345));
    });

    test('slot is preserved as BigInt', () {
      final slot = BigInt.from(999999999);
      final params = getBlockCommitmentParams(slot);
      expect(params[0], slot);
    });
  });
}
