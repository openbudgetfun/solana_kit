import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
import 'package:test/test.dart';

/// Well-known addresses used to build the fixture metadata account.
const _updateAuthority = Address(
  '4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T',
);
const _mint = Address('So11111111111111111111111111111111111111112');
const _creator = Address('Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS');
const _collectionMint = Address('5peNnhAvYmfhrroTUaZKe2ft3iGtNcQC2iExYdVc9yqj');
const _ruleSet = Address('8bs6pySUMXhFqxfhExMGdvR4M9rASv8F4qyrw8Ld5zJw');

/// Builds a fully populated metadata account fixture.
Metadata _fixture() {
  return Metadata(
    key: Key.metadataV1,
    updateAuthority: _updateAuthority,
    mint: _mint,
    data: const Data(
      name: 'Wrapped SOL',
      symbol: 'WSOL',
      uri: 'https://example.com/wrapped-sol.json',
      sellerFeeBasisPoints: 500,
      creators: [
        Creator(
          address: Address('Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS'),
          verified: true,
          share: 100,
        ),
      ],
    ),
    primarySaleHappened: true,
    isMutable: false,
    editionNonce: 254,
    tokenStandard: TokenStandard.programmableNonFungible,
    collection: const Collection(verified: true, key: _collectionMint),
    uses: Uses(
      useMethod: UseMethod.single,
      remaining: BigInt.from(9),
      total: BigInt.from(10),
    ),
    collectionDetails: CollectionDetailsV1(size: BigInt.from(50)),
    programmableConfig: const ProgrammableConfigV1(ruleSet: _ruleSet),
  );
}

void main() {
  group('Metadata account codec', () {
    test('roundtrips a fully populated account', () {
      final metadata = _fixture();

      final bytes = getMetadataEncoder().encode(metadata);
      final decoded = getMetadataDecoder().decode(bytes);

      // Field-by-field for nested collections, since list fields are
      // compared by identity in the synthesized == operator.
      expect(decoded.key, Key.metadataV1);
      expect(decoded.updateAuthority, _updateAuthority);
      expect(decoded.mint, _mint);
      expect(decoded.data.name, 'Wrapped SOL');
      expect(decoded.data.symbol, 'WSOL');
      expect(decoded.data.uri, 'https://example.com/wrapped-sol.json');
      expect(decoded.data.sellerFeeBasisPoints, 500);
      expect(decoded.data.creators, hasLength(1));
      expect(
        decoded.data.creators![0],
        isA<Creator>()
            .having((c) => c.address, 'address', _creator)
            .having((c) => c.verified, 'verified', isTrue)
            .having((c) => c.share, 'share', 100),
      );
      expect(decoded.primarySaleHappened, isTrue);
      expect(decoded.isMutable, isFalse);
      expect(decoded.editionNonce, 254);
      expect(decoded.tokenStandard, TokenStandard.programmableNonFungible);
      expect(decoded.collection!.verified, isTrue);
      expect(decoded.collection!.key, _collectionMint);
      expect(decoded.uses!.useMethod, UseMethod.single);
      expect(decoded.uses!.remaining, BigInt.from(9));
      expect(decoded.uses!.total, BigInt.from(10));
      expect(
        decoded.collectionDetails,
        CollectionDetailsV1(size: BigInt.from(50)),
      );
      expect(
        decoded.programmableConfig,
        isA<ProgrammableConfigV1>().having(
          (config) => config.ruleSet,
          'ruleSet',
          _ruleSet,
        ),
      );
      expect(decoded, metadata);
    });

    test('roundtrips a minimal (legacy) account', () {
      const metadata = Metadata(
        key: Key.metadataV1,
        updateAuthority: Address(
          '4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T',
        ),
        mint: Address('So11111111111111111111111111111111111111112'),
        data: Data(
          name: 'Test',
          symbol: 'TST',
          uri: 'https://example.com/test.json',
          sellerFeeBasisPoints: 0,
          creators: null,
        ),
        primarySaleHappened: false,
        isMutable: true,
        editionNonce: null,
        tokenStandard: null,
        collection: null,
        uses: null,
        collectionDetails: null,
        programmableConfig: null,
      );

      final bytes = getMetadataEncoder().encode(metadata);
      final decoded = getMetadataDecoder().decode(bytes);
      expect(decoded, metadata);
    });

    test('encodes metadata accounts with the canonical on-chain key byte', () {
      // On mainnet, Metadata accounts start with the `Key::MetadataV1`
      // byte, which is index 4 of the generated [Key] enum.
      final bytes = getMetadataEncoder().encode(_fixture());
      expect(bytes.first, 4);
      expect(Key.metadataV1.index, 4);
    });

    test('re-encoding decoded bytes is stable', () {
      final metadata = _fixture();
      final bytes = getMetadataEncoder().encode(metadata);
      final decoded = getMetadataDecoder().decode(bytes);

      expect(getMetadataEncoder().encode(decoded), bytes);
    });
  });
}
