import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const owner = Address('11111111111111111111111111111111');
  const programId = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  group('GetTokenAccountsByOwnerConfig', () {
    test('serializes account encoding values', () {
      const config = GetTokenAccountsByOwnerConfig(
        commitment: Commitment.finalized,
        encoding: AccountEncoding.base64Zstd,
      );

      expect(config.toJson(), {
        'commitment': 'finalized',
        'encoding': 'base64+zstd',
      });
    });
  });

  test('params serialize owner, filter, and config', () {
    final params = getTokenAccountsByOwnerParams(
      owner,
      {'programId': programId.value},
      const GetTokenAccountsByOwnerConfig(encoding: AccountEncoding.base58),
    );

    expect(params[0], owner.value);
    expect(params[1], {'programId': programId.value});
    expect(params[2], {'encoding': 'base58'});
  });
}
