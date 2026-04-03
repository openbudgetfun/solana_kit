import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:test/test.dart';

void main() {
  const addressA = Address('11111111111111111111111111111111');
  const addressB = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  group('getRecentPrioritizationFeesParams', () {
    test('returns empty list when no addresses provided', () {
      final params = getRecentPrioritizationFeesParams();
      expect(params, isEmpty);
    });

    test('returns list with address strings when addresses provided', () {
      final params =
          getRecentPrioritizationFeesParams([addressA, addressB]);
      expect(params, hasLength(1));
      expect(params[0], [addressA.value, addressB.value]);
    });

    test('handles single address', () {
      final params = getRecentPrioritizationFeesParams([addressA]);
      expect(params, hasLength(1));
      expect(params[0], [addressA.value]);
    });

    test('handles empty address list', () {
      final params = getRecentPrioritizationFeesParams([]);
      expect(params, hasLength(1));
      expect(params[0], isEmpty);
    });
  });
}
