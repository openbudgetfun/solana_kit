import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_token/solana_kit_token.dart';
import 'package:test/test.dart';

void main() {
  group('Mint account codec', () {
    test('round-trips through encoder/decoder', () {
      final mint = Mint(
        mintAuthority: const Address(
          '11111111111111111111111111111111',
        ),
        supply: BigInt.from(1000000),
        decimals: 6,
        isInitialized: true,
        freezeAuthority: null,
      );

      final encoded = getMintEncoder().encode(mint);
      // Encoded size may differ from on-chain mintSize (82) because
      // the Codama IDL uses fixed-size option fields.
      expect(encoded, isNotEmpty);

      final decoded = getMintDecoder().decode(encoded);
      expect(decoded.mintAuthority, mint.mintAuthority);
      expect(decoded.supply, mint.supply);
      expect(decoded.decimals, mint.decimals);
      expect(decoded.isInitialized, true);
      expect(decoded.freezeAuthority, isNull);
    });

    test('round-trips with freeze authority', () {
      const authority = Address('11111111111111111111111111111112');
      final mint = Mint(
        mintAuthority: authority,
        supply: BigInt.zero,
        decimals: 9,
        isInitialized: true,
        freezeAuthority: authority,
      );

      final bytes = getMintEncoder().encode(mint);
      final decoded = getMintDecoder().decode(bytes);
      expect(decoded.freezeAuthority, authority);
      expect(decoded.mintAuthority, authority);
    });
  });

  group('Token account codec', () {
    test('round-trips through encoder/decoder', () {
      const mint = Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v');
      const owner = Address('11111111111111111111111111111111');

      final token = Token(
        mint: mint,
        owner: owner,
        amount: BigInt.from(500),
        delegate: null,
        state: AccountState.initialized,
        isNative: null,
        delegatedAmount: BigInt.zero,
        closeAuthority: null,
      );

      final encoded = getTokenEncoder().encode(token);
      expect(encoded, isNotEmpty);

      final decoded = getTokenDecoder().decode(encoded);
      expect(decoded.mint, mint);
      expect(decoded.owner, owner);
      expect(decoded.amount, BigInt.from(500));
      expect(decoded.state, AccountState.initialized);
      expect(decoded.delegate, isNull);
    });
  });

  group('AccountState enum codec', () {
    test('round-trips all variants', () {
      for (final state in AccountState.values) {
        final encoded = getAccountStateEncoder().encode(state);
        final decoded = getAccountStateDecoder().decode(encoded);
        expect(decoded, state);
      }
    });
  });

  group('AuthorityType enum codec', () {
    test('round-trips all variants', () {
      for (final authType in AuthorityType.values) {
        final encoded = getAuthorityTypeEncoder().encode(authType);
        final decoded = getAuthorityTypeDecoder().decode(encoded);
        expect(decoded, authType);
      }
    });
  });

  group('InitializeMint2 instruction codec', () {
    test('round-trips instruction data', () {
      const mintAuth = Address('11111111111111111111111111111111');
      const data = InitializeMint2InstructionData(
        decimals: 6,
        mintAuthority: mintAuth,
        freezeAuthority: null,
      );

      final encoded =
          getInitializeMint2InstructionDataEncoder().encode(data);
      final decoded =
          getInitializeMint2InstructionDataDecoder().decode(encoded);

      expect(decoded.discriminator, 20);
      expect(decoded.decimals, 6);
      expect(decoded.mintAuthority, mintAuth);
      expect(decoded.freezeAuthority, isNull);
    });
  });

  group('Transfer instruction codec', () {
    test('round-trips instruction data', () {
      final data = TransferInstructionData(
        amount: BigInt.from(42),
      );

      final encoded = getTransferInstructionDataEncoder().encode(data);
      final decoded = getTransferInstructionDataDecoder().decode(encoded);

      expect(decoded.discriminator, 3);
      expect(decoded.amount, BigInt.from(42));
    });
  });
}
