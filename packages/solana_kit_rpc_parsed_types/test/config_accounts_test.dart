import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:test/test.dart';

void main() {
  group('JsonParsedConfigProgramAccount', () {
    test('can construct a stakeConfig account', () {
      const account = JsonParsedStakeConfig(
        info: JsonParsedStakeConfigInfo(
          slashPenalty: 12,
          warmupCooldownRate: 0.25,
        ),
      );

      expect(account.type, 'stakeConfig');
      expect(account.info.slashPenalty, 12);
      expect(account.info.warmupCooldownRate, 0.25);
      expect(account, isA<JsonParsedConfigProgramAccount>());
    });

    test('can construct a validatorInfo account', () {
      const account = JsonParsedValidatorInfo(
        info: JsonParsedValidatorInfoData(
          configData: {
            'name': 'HoldTheNode',
            'website': 'https://holdthenode.com',
          },
          keys: [
            JsonParsedValidatorInfoKey(
              pubkey: Address('Va1idator1nfo111111111111111111111111111111'),
              signer: false,
            ),
            JsonParsedValidatorInfoKey(
              pubkey: Address('5hvJ19nRgtzAkosb5bcx9bqeN2QA1Qwxq4M349Q2L6s2'),
              signer: true,
            ),
          ],
        ),
      );

      expect(account.type, 'validatorInfo');
      expect(account.info.keys, hasLength(2));
      expect(
        account.info.keys[0].pubkey.value,
        'Va1idator1nfo111111111111111111111111111111',
      );
      expect(account.info.keys[0].signer, isFalse);
      expect(account.info.keys[1].signer, isTrue);
      expect(account, isA<JsonParsedConfigProgramAccount>());
    });

    test('can discriminate via sealed class', () {
      const JsonParsedConfigProgramAccount account = JsonParsedStakeConfig(
        info: JsonParsedStakeConfigInfo(
          slashPenalty: 12,
          warmupCooldownRate: 0.25,
        ),
      );

      switch (account) {
        case JsonParsedStakeConfig(:final info):
          expect(info.slashPenalty, 12);
        case JsonParsedValidatorInfo():
          fail('Expected stakeConfig, got validatorInfo');
      }
    });
  });
}
