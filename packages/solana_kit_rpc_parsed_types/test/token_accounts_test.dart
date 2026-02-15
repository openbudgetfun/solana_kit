import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('JsonParsedTokenProgramAccount', () {
    test('can construct a token account', () {
      const account = JsonParsedTokenAccountVariant(
        info: JsonParsedTokenAccount(
          isNative: false,
          mint: Address('Gh9ZwEmdLJ8DscKNTkTqPbNwLNNBjuSzaG9Vp2KGtKJr'),
          owner: Address('6UsGbaMgchgj4wiwKKuE1v5URHdcDfEiMSM25QpesKir'),
          state: TokenAccountState.initialized,
          tokenAmount: TokenAmount(
            amount: StringifiedBigInt('9999999779500000'),
            decimals: 6,
            uiAmountString: StringifiedNumber('9999999779.5'),
          ),
        ),
      );

      expect(account.type, 'account');
      expect(
        account.info.mint.value,
        'Gh9ZwEmdLJ8DscKNTkTqPbNwLNNBjuSzaG9Vp2KGtKJr',
      );
      expect(
        account.info.owner.value,
        '6UsGbaMgchgj4wiwKKuE1v5URHdcDfEiMSM25QpesKir',
      );
      expect(account.info.isNative, isFalse);
      expect(account.info.state, TokenAccountState.initialized);
      expect(account.info.tokenAmount.amount.value, '9999999779500000');
      expect(account.info.tokenAmount.decimals, 6);
      expect(account, isA<JsonParsedTokenProgramAccount>());
    });

    test('can construct a mint account', () {
      const account = JsonParsedMintAccount(
        info: JsonParsedMintInfo(
          decimals: 6,
          isInitialized: true,
          supply: StringifiedBigInt('1792635195340523528'),
          mintAuthority: Address(
            'Gh9ZwEmdLJ8DscKNTkTqPbNwLNNBjuSzaG9Vp2KGtKJr',
          ),
        ),
      );

      expect(account.type, 'mint');
      expect(account.info.decimals, 6);
      expect(account.info.isInitialized, isTrue);
      expect(account.info.supply.value, '1792635195340523528');
      expect(
        account.info.mintAuthority?.value,
        'Gh9ZwEmdLJ8DscKNTkTqPbNwLNNBjuSzaG9Vp2KGtKJr',
      );
      expect(account.info.freezeAuthority, isNull);
      expect(account, isA<JsonParsedTokenProgramAccount>());
    });

    test('can construct a multisig account', () {
      const account = JsonParsedMultisigAccount(
        info: JsonParsedMultisigInfo(
          isInitialized: true,
          numRequiredSigners: 2,
          numValidSigners: 2,
          signers: [
            Address('Fkc4FN7PPhyGsAcHPW3dBBJ4BvtYkDr2rBFBgFpvy3nB'),
            Address('5scSndUhfZJ8j8wZz5UNHhvuPBhvN1RboTdkKSvFHLtW'),
          ],
        ),
      );

      expect(account.type, 'multisig');
      expect(account.info.isInitialized, isTrue);
      expect(account.info.numRequiredSigners, 2);
      expect(account.info.numValidSigners, 2);
      expect(account.info.signers, hasLength(2));
      expect(account, isA<JsonParsedTokenProgramAccount>());
    });

    test('can discriminate via sealed class', () {
      const JsonParsedTokenProgramAccount account = JsonParsedMintAccount(
        info: JsonParsedMintInfo(
          decimals: 6,
          isInitialized: true,
          supply: StringifiedBigInt('1792635195340523528'),
        ),
      );

      switch (account) {
        case JsonParsedMintAccount(:final info):
          expect(info.supply.value, '1792635195340523528');
        case JsonParsedTokenAccountVariant():
          fail('Expected mint, got account');
        case JsonParsedMultisigAccount():
          fail('Expected mint, got multisig');
      }
    });
  });
}
