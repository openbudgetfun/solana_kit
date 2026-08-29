import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
import 'package:test/test.dart';

/// Program address of the mpl-token-metadata program.
const _programAddress = 'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s';

/// The mint of Wrapped SOL on mainnet, used as the mint input for all
/// expected PDA vectors.
const _mint = Address('So11111111111111111111111111111111111111112');

/// Other well-known addresses used as inputs for the expected PDA vectors.
const _authority = Address('9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin');
const _token = Address('4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T');
const _updateAuthority = Address(
  'Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS',
);
const _delegate = Address('4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T');

void main() {
  group('findMetadataPda', () {
    test('matches the expected address from the upstream JS SDK', () async {
      // Expected vector derived with the official Metaplex client
      // (@metaplex-foundation/mpl-token-metadata-kit build from
      // mpl-token-metadata, using @solana/kit's getProgramDerivedAddress).
      final (pda, bump) = await findMetadataPda(mint: _mint);
      expect(
        pda,
        const Address('6dM4TqWyWJsbx7obrdLcviBkTafD5E8av61zfU6jq57X'),
      );
      expect(bump, 255);
    });

    test('is deterministic', () async {
      final first = await findMetadataPda(mint: _mint);
      final second = await findMetadataPda(mint: _mint);
      expect(first.$1, second.$1);
      expect(first.$2, second.$2);
    });
  });

  group('findMasterEditionPda', () {
    test('matches the expected address from the upstream JS SDK', () async {
      final (pda, bump) = await findMasterEditionPda(mint: _mint);
      expect(
        pda,
        const Address('7r1W5yu5i7ev1wPNGsNuRLcdKW1sCy2x4rwyQkdi9ew2'),
      );
      expect(bump, 254);
    });

    test('is deterministic', () async {
      final first = await findMasterEditionPda(mint: _mint);
      final second = await findMasterEditionPda(mint: _mint);
      expect(first.$1, second.$1);
      expect(first.$2, second.$2);
    });
  });

  group('findEditionMarkerPda', () {
    test('uses floor(edition / 248) as the seed for edition 247', () async {
      // Edition 247 falls within the first marker (floor(247 / 248) == 0).
      final (pda, bump) = await findEditionMarkerPda(mint: _mint, edition: 247);
      expect(
        pda,
        const Address('4Y1mQRDnq8F8vrvtkgte6Pi1LFgRSqVRXtqh2eMsRyBs'),
      );
      expect(bump, 253);
    });

    test('uses floor(edition / 248) as the seed for edition 761', () async {
      // Edition 761 falls within the fourth marker (floor(761 / 248) == 3).
      final (pda, bump) = await findEditionMarkerPda(mint: _mint, edition: 761);
      expect(
        pda,
        const Address('DnAhDZ8svTpU2fJ9ZNkJtKJmeMLnbUG2rJLbRdArM2Si'),
      );
      expect(bump, 254);
    });

    test('is deterministic', () async {
      final first = await findEditionMarkerPda(mint: _mint, edition: 42);
      final second = await findEditionMarkerPda(mint: _mint, edition: 42);
      expect(first.$1, second.$1);
      expect(first.$2, second.$2);
    });
  });

  group('findEditionMarkerV2Pda', () {
    test('matches the expected address from the upstream JS SDK', () async {
      final (pda, bump) = await findEditionMarkerV2Pda(mint: _mint);
      expect(
        pda,
        const Address('AtKgUUJsLTPt73NBSpAyJEpth4D9Ra5aby8osTexGZZh'),
      );
      expect(bump, 255);
    });

    test('is deterministic', () async {
      final first = await findEditionMarkerV2Pda(mint: _mint);
      final second = await findEditionMarkerV2Pda(mint: _mint);
      expect(first.$1, second.$1);
      expect(first.$2, second.$2);
    });
  });

  group('findCollectionAuthorityRecordPda', () {
    test('matches the expected address from the upstream JS SDK', () async {
      final (pda, bump) = await findCollectionAuthorityRecordPda(
        mint: _mint,
        collectionAuthority: _authority,
      );
      expect(
        pda,
        const Address('8bs6pySUMXhFqxfhExMGdvR4M9rASv8F4qyrw8Ld5zJw'),
      );
      expect(bump, 255);
    });

    test('is deterministic', () async {
      final first = await findCollectionAuthorityRecordPda(
        mint: _mint,
        collectionAuthority: _authority,
      );
      final second = await findCollectionAuthorityRecordPda(
        mint: _mint,
        collectionAuthority: _authority,
      );
      expect(first.$1, second.$1);
      expect(first.$2, second.$2);
    });
  });

  group('findUseAuthorityRecordPda', () {
    test('matches the expected address from the upstream JS SDK', () async {
      final (pda, bump) = await findUseAuthorityRecordPda(
        mint: _mint,
        useAuthority: _authority,
      );
      expect(
        pda,
        const Address('524rRBfxrFVGfVF91wQydFtNNAeV3GVEgKB83XTfZjMz'),
      );
      expect(bump, 255);
    });

    test('is deterministic', () async {
      final first = await findUseAuthorityRecordPda(
        mint: _mint,
        useAuthority: _authority,
      );
      final second = await findUseAuthorityRecordPda(
        mint: _mint,
        useAuthority: _authority,
      );
      expect(first.$1, second.$1);
      expect(first.$2, second.$2);
    });
  });

  group('findTokenRecordPda', () {
    test('matches the expected address from the upstream JS SDK', () async {
      final (pda, bump) = await findTokenRecordPda(mint: _mint, token: _token);
      expect(
        pda,
        const Address('9nRgosXsTzVLb9P11px73AcFgyNxgngh4LF6BBEF1H71'),
      );
      expect(bump, 254);
    });

    test('is deterministic', () async {
      final first = await findTokenRecordPda(mint: _mint, token: _token);
      final second = await findTokenRecordPda(mint: _mint, token: _token);
      expect(first.$1, second.$1);
      expect(first.$2, second.$2);
    });
  });

  group('findMetadataDelegateRecordPda', () {
    test('matches the expected address for the collection role', () async {
      final (pda, bump) = await findMetadataDelegateRecordPda(
        mint: _mint,
        delegateRole: MetadataDelegateRole.collection,
        updateAuthority: _updateAuthority,
        delegate: _delegate,
      );
      expect(
        pda,
        const Address('8QJbxizyAHwNcoj5EEA1cbBgGVrkdFFsH8jV7s2yx36R'),
      );
      expect(bump, 255);
    });

    test('matches the expected address for the use role', () async {
      final (pda, bump) = await findMetadataDelegateRecordPda(
        mint: _mint,
        delegateRole: MetadataDelegateRole.use,
        updateAuthority: _updateAuthority,
        delegate: _delegate,
      );
      expect(
        pda,
        const Address('7CQdCkTkenFpasatq7biRqU7nFHmiJieMndMwoj56ova'),
      );
      expect(bump, 255);
    });

    test('matches the expected address for the authority item role', () async {
      final (pda, bump) = await findMetadataDelegateRecordPda(
        mint: _mint,
        delegateRole: MetadataDelegateRole.authorityItem,
        updateAuthority: _updateAuthority,
        delegate: _delegate,
      );
      expect(
        pda,
        const Address('8effUicKAdhWdH1KGefqXHUGjrKNCpy65vpoygNGJEaQ'),
      );
      expect(bump, 255);
    });

    test('matches the expected address for the data item role', () async {
      final (pda, bump) = await findMetadataDelegateRecordPda(
        mint: _mint,
        delegateRole: MetadataDelegateRole.dataItem,
        updateAuthority: _updateAuthority,
        delegate: _delegate,
      );
      expect(
        pda,
        const Address('BHPMwdpRcizfiFBW6gnh5UpGtaMJf27RX4ESXrDx2nYr'),
      );
      expect(bump, 255);
    });

    test(
      'matches the expected address for the programmable config item role',
      () async {
        final (pda, bump) = await findMetadataDelegateRecordPda(
          mint: _mint,
          delegateRole: MetadataDelegateRole.programmableConfigItem,
          updateAuthority: _updateAuthority,
          delegate: _delegate,
        );
        expect(
          pda,
          const Address('DpFbGapttDXTqPHVis1iGZUmoiNszKr76gGtnahVGrkX'),
        );
        expect(bump, 254);
      },
    );

    test('is deterministic', () async {
      final first = await findMetadataDelegateRecordPda(
        mint: _mint,
        delegateRole: MetadataDelegateRole.collection,
        updateAuthority: _updateAuthority,
        delegate: _delegate,
      );
      final second = await findMetadataDelegateRecordPda(
        mint: _mint,
        delegateRole: MetadataDelegateRole.collection,
        updateAuthority: _updateAuthority,
        delegate: _delegate,
      );
      expect(first.$1, second.$1);
      expect(first.$2, second.$2);
    });
  });

  group('findHolderDelegateRecordPda', () {
    test('matches the expected address for the print delegate role', () async {
      final (pda, bump) = await findHolderDelegateRecordPda(
        mint: _mint,
        owner: _updateAuthority,
        delegate: _delegate,
      );
      expect(
        pda,
        const Address('CrURBYkCru4UmTRqzgxrt88orMy3i8evfHYCJv2ry8cG'),
      );
      expect(bump, 255);
    });

    test('is deterministic', () async {
      final first = await findHolderDelegateRecordPda(
        mint: _mint,
        owner: _updateAuthority,
        delegate: _delegate,
      );
      final second = await findHolderDelegateRecordPda(
        mint: _mint,
        owner: _updateAuthority,
        delegate: _delegate,
      );
      expect(first.$1, second.$1);
      expect(first.$2, second.$2);
    });
  });

  group('findProgramAsBurnerPda', () {
    test('matches the expected address from the upstream JS SDK', () async {
      final (pda, bump) = await findProgramAsBurnerPda();
      expect(
        pda,
        const Address('GKv5PeCxKBCDezo4FMVjjRbkUfoou9PRvPKdzaFEwjXi'),
      );
      expect(bump, 255);
    });

    test('is deterministic', () async {
      final first = await findProgramAsBurnerPda();
      final second = await findProgramAsBurnerPda();
      expect(first.$1, second.$1);
      expect(first.$2, second.$2);
    });
  });

  group('program address', () {
    test('mplTokenMetadataProgramAddress matches the canonical program ID', () {
      expect(mplTokenMetadataProgramAddress, equals(_programAddress));
      expect(
        mplTokenMetadataProgramAddressObject,
        const Address(_programAddress),
      );
    });
  });
}
