import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:test/test.dart';

void main() {
  group('getAgGenesisCertParams', () {
    test('returns an empty params list', () {
      expect(getAgGenesisCertParams(), isEmpty);
    });
  });
}
