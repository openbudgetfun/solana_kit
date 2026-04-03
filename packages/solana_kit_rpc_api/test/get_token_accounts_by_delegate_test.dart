import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const delegate = Address('11111111111111111111111111111111');
  const mint = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  group('GetTokenAccountsByDelegateConfig', () {
    test('serializes account encoding values', () {
      const config = GetTokenAccountsByDelegateConfig(
        commitment: Commitment.confirmed,
        encoding: AccountEncoding.base64,
        dataSlice: DataSlice(offset: 1, length: 2),
      );

      expect(config.toJson(), {
        'commitment': 'confirmed',
        'encoding': 'base64',
        'dataSlice': {'offset': 1, 'length': 2},
      });
    });
  });

  test('mint filter serializes', () {
    const filter = TokenAccountMintFilter(mint: mint);
    expect(filter.toJson(), {'mint': mint.value});
  });

  test('program id filter serializes', () {
    const filter = TokenAccountProgramIdFilter(programId: mint);
    expect(filter.toJson(), {'programId': mint.value});
  });

  test('params serialize delegate, filter, and config', () {
    final params = getTokenAccountsByDelegateParams(
      delegate,
      const TokenAccountMintFilter(mint: mint).toJson(),
      const GetTokenAccountsByDelegateConfig(
        encoding: AccountEncoding.jsonParsed,
      ),
    );

    expect(params[0], delegate.value);
    expect(params[1], {'mint': mint.value});
    expect(params[2], {'encoding': 'jsonParsed'});
  });
}
