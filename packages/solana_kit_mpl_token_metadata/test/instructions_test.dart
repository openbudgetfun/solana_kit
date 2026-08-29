import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
import 'package:test/test.dart';

/// Well-known addresses used as instruction account inputs.
const _metadata = Address('6dM4TqWyWJsbx7obrdLcviBkTafD5E8av61zfU6jq57X');
const _mint = Address('So11111111111111111111111111111111111111112');
const _mintAuthority = Address('9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin');
const _payer = Address('Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS');
const _updateAuthority = Address(
  '4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T',
);
const _systemProgram = Address('11111111111111111111111111111111');
const _collectionMint = Address('5peNnhAvYmfhrroTUaZKe2ft3iGtNcQC2iExYdVc9yqj');
const _collection = Address('8QJbxizyAHwNcoj5EEA1cbBgGVrkdFFsH8jV7s2yx36R');
const _collectionMasterEdition = Address(
  '7r1W5yu5i7ev1wPNGsNuRLcdKW1sCy2x4rwyQkdi9ew2',
);

void main() {
  group('createMetadataAccountV3', () {
    test('encodes and decodes with minimal data roundtrip', () {
      const data = DataV2(
        name: 'Wrapped SOL',
        symbol: 'WSOL',
        uri: 'https://example.com/wrapped-sol.json',
        sellerFeeBasisPoints: 500,
        creators: null,
        collection: null,
        uses: null,
      );

      final instruction = getCreateMetadataAccountV3Instruction(
        programAddress: mplTokenMetadataProgramAddressObject,
        metadata: _metadata,
        mint: _mint,
        mintAuthority: _mintAuthority,
        payer: _payer,
        updateAuthority: _updateAuthority,
        systemProgram: _systemProgram,
        data: data,
        isMutable: true,
        collectionDetails: null,
      );

      // The builder should produce the expected instruction program and
      // accounts.
      expect(instruction.programAddress, mplTokenMetadataProgramAddressObject);
      expect(instruction.accounts, hasLength(6));
      expect(
        instruction.accounts![0],
        _accountMeta(_metadata, AccountRole.writable),
      );
      expect(
        instruction.accounts![1],
        _accountMeta(_mint, AccountRole.readonly),
      );
      expect(
        instruction.accounts![2],
        _accountMeta(_mintAuthority, AccountRole.readonlySigner),
      );
      expect(
        instruction.accounts![3],
        _accountMeta(_payer, AccountRole.writableSigner),
      );
      expect(
        instruction.accounts![4],
        _accountMeta(_updateAuthority, AccountRole.readonlySigner),
      );
      expect(
        instruction.accounts![5],
        _accountMeta(_systemProgram, AccountRole.readonly),
      );

      // The discriminator of createMetadataAccountV3 is 33.
      expect(instruction.data!.first, 33);

      // Parsing the instruction back returns the same arguments.
      final parsed = parseCreateMetadataAccountV3Instruction(instruction);
      expect(parsed.discriminator, 33);
      expect(parsed.data, data);
      expect(parsed.isMutable, isTrue);
      expect(parsed.collectionDetails, isNull);
    });

    test('encodes and decodes with creators and collection details', () {
      final data = DataV2(
        name: 'Test',
        symbol: 'TST',
        uri: 'https://example.com/test.json',
        sellerFeeBasisPoints: 100,
        creators: const [
          Creator(address: _payer, verified: true, share: 100),
        ],
        collection: const Collection(verified: false, key: _collectionMint),
        uses: Uses(
          useMethod: UseMethod.burn,
          remaining: BigInt.from(9),
          total: BigInt.from(10),
        ),
      );

      final instruction = getCreateMetadataAccountV3Instruction(
        programAddress: mplTokenMetadataProgramAddressObject,
        metadata: _metadata,
        mint: _mint,
        mintAuthority: _mintAuthority,
        payer: _payer,
        updateAuthority: _updateAuthority,
        systemProgram: _systemProgram,
        data: data,
        isMutable: false,
        collectionDetails: CollectionDetailsV1(size: BigInt.from(50)),
      );

      final parsed = parseCreateMetadataAccountV3Instruction(instruction);
      expect(parsed.discriminator, 33);
      expect(parsed.data.name, 'Test');
      expect(parsed.data.symbol, 'TST');
      expect(parsed.data.uri, 'https://example.com/test.json');
      expect(parsed.data.sellerFeeBasisPoints, 100);
      expect(
        parsed.data.creators!.map(
          (creator) => (creator.address, creator.verified, creator.share),
        ),
        contains((
          const Address('Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS'),
          true,
          100,
        )),
      );
      expect(parsed.data.collection!.verified, isFalse);
      expect(parsed.data.collection!.key, _collectionMint);
      expect(parsed.data.uses!.useMethod, UseMethod.burn);
      expect(parsed.data.uses!.remaining, BigInt.from(9));
      expect(parsed.data.uses!.total, BigInt.from(10));
      expect(parsed.isMutable, isFalse);
      expect(parsed.collectionDetails, isA<CollectionDetailsV1>());
      expect(
        (parsed.collectionDetails! as CollectionDetailsV1).size,
        BigInt.from(50),
      );
    });
  });

  group('updateMetadataAccountV2', () {
    test('encodes and decodes all optional fields set', () {
      const newData = DataV2(
        name: 'Updated',
        symbol: 'UPD',
        uri: 'https://example.com/updated.json',
        sellerFeeBasisPoints: 250,
        creators: null,
        collection: null,
        uses: null,
      );

      final instruction = getUpdateMetadataAccountV2Instruction(
        programAddress: mplTokenMetadataProgramAddressObject,
        metadata: _metadata,
        updateAuthority: _updateAuthority,
        data: newData,
        newUpdateAuthority: _payer,
        primarySaleHappened: true,
        isMutable: false,
      );

      expect(instruction.programAddress, mplTokenMetadataProgramAddressObject);
      expect(instruction.accounts, hasLength(2));
      expect(
        instruction.accounts![0],
        _accountMeta(_metadata, AccountRole.writable),
      );
      expect(
        instruction.accounts![1],
        _accountMeta(_updateAuthority, AccountRole.readonlySigner),
      );

      // The discriminator of updateMetadataAccountV2 is 15.
      expect(instruction.data!.first, 15);

      final parsed = parseUpdateMetadataAccountV2Instruction(instruction);
      expect(parsed.discriminator, 15);
      expect(parsed.data, newData);
      expect(parsed.newUpdateAuthority, _payer);
      expect(parsed.primarySaleHappened, isTrue);
      expect(parsed.isMutable, isFalse);
    });

    test('encodes and decodes all optional fields unset', () {
      final instruction = getUpdateMetadataAccountV2Instruction(
        programAddress: mplTokenMetadataProgramAddressObject,
        metadata: _metadata,
        updateAuthority: _updateAuthority,
        data: null,
        newUpdateAuthority: null,
        primarySaleHappened: null,
        isMutable: null,
      );

      // Four nullable values encode as four zero-size prefixes.
      // u8 discriminant (1) + 4 option bytes = 5 bytes total.
      expect(instruction.data, hasLength(5));
      expect(instruction.data!.first, 15);

      final parsed = parseUpdateMetadataAccountV2Instruction(instruction);
      expect(parsed.data, isNull);
      expect(parsed.newUpdateAuthority, isNull);
      expect(parsed.primarySaleHappened, isNull);
      expect(parsed.isMutable, isNull);
    });
  });

  group('verifyCollection', () {
    test('encodes and decodes with empty data', () {
      final instruction = getVerifyCollectionInstruction(
        programAddress: mplTokenMetadataProgramAddressObject,
        metadata: _metadata,
        collectionAuthority: _updateAuthority,
        payer: _payer,
        collectionMint: _collectionMint,
        collection: _collection,
        collectionMasterEditionAccount: _collectionMasterEdition,
      );

      expect(instruction.programAddress, mplTokenMetadataProgramAddressObject);
      expect(instruction.accounts, hasLength(6));
      expect(
        instruction.accounts![0],
        _accountMeta(_metadata, AccountRole.writable),
      );
      expect(
        instruction.accounts![1],
        _accountMeta(_updateAuthority, AccountRole.writableSigner),
      );
      expect(
        instruction.accounts![2],
        _accountMeta(_payer, AccountRole.writableSigner),
      );
      expect(
        instruction.accounts![3],
        _accountMeta(_collectionMint, AccountRole.readonly),
      );
      expect(
        instruction.accounts![4],
        _accountMeta(_collection, AccountRole.readonly),
      );
      expect(
        instruction.accounts![5],
        _accountMeta(_collectionMasterEdition, AccountRole.readonly),
      );

      // The discriminator of verifyCollection is 18 and the instruction
      // carries no additional arguments.
      expect(instruction.data, Uint8List.fromList([18]));

      final parsed = parseVerifyCollectionInstruction(instruction);
      expect(parsed.discriminator, 18);
    });

    test('includes the collection authority record when provided', () {
      const record = Address(
        '8bs6pySUMXhFqxfhExMGdvR4M9rASv8F4qyrw8Ld5zJw',
      );

      final instruction = getVerifyCollectionInstruction(
        programAddress: mplTokenMetadataProgramAddressObject,
        metadata: _metadata,
        collectionAuthority: _updateAuthority,
        payer: _payer,
        collectionMint: _collectionMint,
        collection: _collection,
        collectionMasterEditionAccount: _collectionMasterEdition,
        collectionAuthorityRecord: record,
      );
      expect(instruction.accounts, hasLength(7));
      expect(
        instruction.accounts![6],
        _accountMeta(record, AccountRole.readonly),
      );

      final parsed = parseVerifyCollectionInstruction(instruction);
      expect(parsed.discriminator, 18);
    });
  });

  group('parseMplTokenMetadataInstruction', () {
    test('identifies createMetadataAccountV3 instructions', () {
      final instruction = getCreateMetadataAccountV3Instruction(
        programAddress: mplTokenMetadataProgramAddressObject,
        metadata: _metadata,
        mint: _mint,
        mintAuthority: _mintAuthority,
        payer: _payer,
        updateAuthority: _updateAuthority,
        systemProgram: _systemProgram,
        data: const DataV2(
          name: 'x',
          symbol: 'x',
          uri: 'x',
          sellerFeeBasisPoints: 0,
          creators: null,
          collection: null,
          uses: null,
        ),
        isMutable: true,
        collectionDetails: null,
      );

      final parsed = parseMplTokenMetadataInstruction(instruction);
      expect(
        parsed,
        isA<ParsedCreateMetadataAccountV3>().having(
          (p) => p.instructionType,
          'instructionType',
          MplTokenMetadataInstruction.createMetadataAccountV3,
        ),
      );
      expect(
        (parsed as ParsedCreateMetadataAccountV3).data.discriminator,
        33,
      );
    });

    test('identifies verifyCollection instructions', () {
      final instruction = getVerifyCollectionInstruction(
        programAddress: mplTokenMetadataProgramAddressObject,
        metadata: _metadata,
        collectionAuthority: _updateAuthority,
        payer: _payer,
        collectionMint: _collectionMint,
        collection: _collection,
        collectionMasterEditionAccount: _collectionMasterEdition,
      );

      final parsed = parseMplTokenMetadataInstruction(instruction);
      expect(parsed, isA<ParsedVerifyCollection>());
      expect(
        parsed.instructionType,
        MplTokenMetadataInstruction.verifyCollection,
      );
    });
  });
}

/// Matches an [AccountMeta] with the expected [address] and [role].
Matcher _accountMeta(Address address, AccountRole role) => isA<AccountMeta>()
    .having((meta) => meta.address, 'address', address)
    .having((meta) => meta.role, 'role', role);
