import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const tokenMint = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  group('GetTokenSupplyConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetTokenSupplyConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetTokenSupplyConfig(commitment: Commitment.finalized);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'finalized');
    });
  });

  group('getTokenSupplyParams', () {
    test('returns list with only mint when no config', () {
      final params = getTokenSupplyParams(tokenMint);
      expect(params, hasLength(1));
      expect(params[0], tokenMint.value);
    });

    test('returns list with mint and config when config provided', () {
      final params = getTokenSupplyParams(
        tokenMint,
        const GetTokenSupplyConfig(commitment: Commitment.confirmed),
      );
      expect(params, hasLength(2));
      expect(params[0], tokenMint.value);
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
    });
  });
}
