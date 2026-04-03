import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const program = Address('11111111111111111111111111111111');

  group('GetProgramAccountsConfig', () {
    test('serializes account encoding values', () {
      const config = GetProgramAccountsConfig(
        commitment: Commitment.finalized,
        encoding: AccountEncoding.base64,
        dataSlice: DataSlice(offset: 0, length: 32),
        filters: [
          {'dataSize': 165},
        ],
        withContext: true,
      );

      expect(config.toJson(), {
        'commitment': 'finalized',
        'encoding': 'base64',
        'dataSlice': {'offset': 0, 'length': 32},
        'filters': [
          {'dataSize': 165},
        ],
        'withContext': true,
      });
    });
  });

  group('getProgramAccountsParams', () {
    test('serializes program address and config', () {
      final params = getProgramAccountsParams(
        program,
        const GetProgramAccountsConfig(encoding: AccountEncoding.jsonParsed),
      );

      expect(params[0], program.value);
      expect(params[1], {'encoding': 'jsonParsed'});
    });
  });
}
