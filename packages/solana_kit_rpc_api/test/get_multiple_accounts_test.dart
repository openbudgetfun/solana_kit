import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const addresses = [
    Address('11111111111111111111111111111111'),
    Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
  ];

  group('GetMultipleAccountsConfig', () {
    test('serializes account encoding values', () {
      const config = GetMultipleAccountsConfig(
        commitment: Commitment.processed,
        encoding: AccountEncoding.base64Zstd,
        dataSlice: DataSlice(offset: 4, length: 8),
      );

      expect(config.toJson(), {
        'commitment': 'processed',
        'encoding': 'base64+zstd',
        'dataSlice': {'offset': 4, 'length': 8},
      });
    });
  });

  group('getMultipleAccountsParams', () {
    test('serializes address list and config', () {
      final params = getMultipleAccountsParams(
        addresses,
        const GetMultipleAccountsConfig(encoding: AccountEncoding.jsonParsed),
      );

      expect(params[0], [for (final address in addresses) address.value]);
      expect(params[1], {'encoding': 'jsonParsed'});
    });
  });
}
