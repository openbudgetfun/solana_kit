import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const testAddress = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  group('GetTokenAccountBalanceConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetTokenAccountBalanceConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config =
          GetTokenAccountBalanceConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'confirmed');
    });
  });

  group('getTokenAccountBalanceParams', () {
    test('returns list with only address when no config', () {
      final params = getTokenAccountBalanceParams(testAddress);
      expect(params, hasLength(1));
      expect(params[0], testAddress.value);
    });

    test('returns list with address and config when config provided', () {
      final params = getTokenAccountBalanceParams(
        testAddress,
        const GetTokenAccountBalanceConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(2));
      expect(params[0], testAddress.value);
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'finalized');
    });
  });
}
