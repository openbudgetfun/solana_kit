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

    test('StakeConfigInfo equality, hashCode, and toString', () {
      const info1 = JsonParsedStakeConfigInfo(
        slashPenalty: 12,
        warmupCooldownRate: 0.25,
      );
      const info2 = JsonParsedStakeConfigInfo(
        slashPenalty: 12,
        warmupCooldownRate: 0.25,
      );
      const info3 = JsonParsedStakeConfigInfo(
        slashPenalty: 50,
        warmupCooldownRate: 0.25,
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
      expect(info1.toString(), contains('slashPenalty'));
    });

    test('ValidatorInfoData equality, hashCode, and toString', () {
      const info1 = JsonParsedValidatorInfoData(
        configData: {'name': 'Test'},
        keys: [
          JsonParsedValidatorInfoKey(
            pubkey: Address('Va1idator1nfo111111111111111111111111111111'),
            signer: true,
          ),
        ],
      );
      const info2 = JsonParsedValidatorInfoData(
        configData: {'name': 'Test'},
        keys: [
          JsonParsedValidatorInfoKey(
            pubkey: Address('Va1idator1nfo111111111111111111111111111111'),
            signer: true,
          ),
        ],
      );
      const info3 = JsonParsedValidatorInfoData(
        configData: {'name': 'Different'},
        keys: [],
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
      expect(info1.toString(), contains('configData'));
    });

    test('ValidatorInfoKey equality, hashCode, and toString', () {
      const key1 = JsonParsedValidatorInfoKey(
        pubkey: Address('Va1idator1nfo111111111111111111111111111111'),
        signer: true,
      );
      const key2 = JsonParsedValidatorInfoKey(
        pubkey: Address('Va1idator1nfo111111111111111111111111111111'),
        signer: true,
      );
      const key3 = JsonParsedValidatorInfoKey(
        pubkey: Address('Va1idator1nfo111111111111111111111111111111'),
        signer: false,
      );

      expect(key1, equals(key2));
      expect(key1.hashCode, equals(key2.hashCode));
      expect(key1 == key3, isFalse);
      expect(key1.toString(), contains('pubkey'));
    });
  });
}
