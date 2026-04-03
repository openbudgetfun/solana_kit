import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:test/test.dart';

void main() {
  group('getRecentPerformanceSamplesParams', () {
    test('returns empty list when no limit provided', () {
      final params = getRecentPerformanceSamplesParams();
      expect(params, isEmpty);
    });

    test('returns list with limit when limit provided', () {
      final params = getRecentPerformanceSamplesParams(32);
      expect(params, hasLength(1));
      expect(params[0], 32);
    });

    test('limit value is preserved as int', () {
      final params = getRecentPerformanceSamplesParams(720);
      expect(params[0], 720);
    });
  });
}
