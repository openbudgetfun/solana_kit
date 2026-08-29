import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart';
import 'package:test/test.dart';

void main() {
  const programAddress = mplCoreProgramAddressObject;
  const systemProgram = Address('11111111111111111111111111111111');
  const noopProgram = Address('noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV');
  const asset = Address('So11111111111111111111111111111111111111112');
  const collection = Address('9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM');
  const authority = Address('4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T');
  const payer = Address('G2ekPPJ6DcUdCNhX9rpuTzQuYsToBp1RQMBdhEXfTmFE');

  group('createV1', () {
    final instruction = getCreateV1Instruction(
      programAddress: programAddress,
      asset: asset,
      collection: collection,
      authority: authority,
      payer: payer,
      owner: authority,
      updateAuthority: collection,
      systemProgram: systemProgram,
      logWrapper: noopProgram,
      dataState: DataState.accountState,
      name: 'My Asset',
      uri: 'https://example.com/asset.json',
      plugins: [
        const PluginAuthorityPair(
          plugin: PluginFreezeDelegate(FreezeDelegate(frozen: false)),
          authority: null,
        ),
      ],
    );

    test('uses the createV1 discriminator and program', () {
      expect(instruction.programAddress, programAddress);
      expect(instruction.data![0], 0);
    });

    test('places accounts in the documented order and roles', () {
      final metas = instruction.accounts!;

      expect(metas, hasLength(8));
      expect(metas[0].address, asset);
      expect(metas[0].role, AccountRole.writableSigner);
      expect(metas[1].address, collection);
      expect(metas[1].role, AccountRole.writable);
      expect(metas[2].address, authority);
      expect(metas[2].role, AccountRole.readonlySigner);
      expect(metas[3].address, payer);
      expect(metas[3].role, AccountRole.writableSigner);
      expect(metas[4].address, authority);
      expect(metas[4].role, AccountRole.readonly);
      expect(metas[5].address, collection);
      expect(metas[5].role, AccountRole.readonly);
      expect(metas[6].address, systemProgram);
      expect(metas[6].role, AccountRole.readonly);
      expect(metas[7].address, noopProgram);
      expect(metas[7].role, AccountRole.readonly);
    });

    test('parses back into the same instruction data', () {
      final parsed = parseCreateV1Instruction(instruction);

      expect(parsed.dataState, DataState.accountState);
      expect(parsed.name, 'My Asset');
      expect(parsed.uri, 'https://example.com/asset.json');
      expect(parsed.plugins, hasLength(1));
      expect(
        parsed.plugins![0].plugin,
        const PluginFreezeDelegate(FreezeDelegate(frozen: false)),
      );

      // The parsed data re-encodes to the exact original bytes.
      expect(
        getCreateV1InstructionDataEncoder().encode(parsed),
        instruction.data,
      );
    });

    test('roundtrips dataState.ledgerState and null plugins', () {
      final minimal = getCreateV1Instruction(
        programAddress: programAddress,
        asset: asset,
        payer: payer,
        systemProgram: systemProgram,
        dataState: DataState.ledgerState,
        name: '',
        uri: '',
        plugins: null,
      );

      final parsed = parseCreateV1Instruction(minimal);

      expect(parsed.dataState, DataState.ledgerState);
      expect(parsed.name, '');
      expect(parsed.uri, '');
      expect(parsed.plugins, isNull);
      expect(
        getCreateV1InstructionDataEncoder().encode(parsed),
        minimal.data,
      );
    });

    test('identifies and parses through the program dispatcher', () {
      expect(
        identifyMplCoreInstruction(instruction.data!),
        MplCoreInstruction.createV1,
      );

      final parsed = parseMplCoreInstruction(instruction);
      expect(parsed, isA<ParsedCreateV1>());
      expect((parsed as ParsedCreateV1).data.name, 'My Asset');
    });
  });

  group('createCollectionV1', () {
    final instruction = getCreateCollectionV1Instruction(
      programAddress: programAddress,
      collection: collection,
      updateAuthority: authority,
      payer: payer,
      systemProgram: systemProgram,
      name: 'My Collection',
      uri: 'https://example.com/collection.json',
      plugins: [
        const PluginAuthorityPair(
          plugin: PluginRoyalties(
            Royalties(
              basisPoints: 500,
              creators: [Creator(address: authority, percentage: 100)],
              ruleSet: RuleSetNone(),
            ),
          ),
          authority: null,
        ),
      ],
    );

    test('uses the createCollectionV1 discriminator and program', () {
      expect(instruction.programAddress, programAddress);
      expect(instruction.data![0], 1);
    });

    test('places accounts in the documented order and roles', () {
      final metas = instruction.accounts!;

      expect(metas, hasLength(4));
      expect(metas[0].address, collection);
      expect(metas[0].role, AccountRole.writableSigner);
      expect(metas[1].address, authority);
      expect(metas[1].role, AccountRole.readonly);
      expect(metas[2].address, payer);
      expect(metas[2].role, AccountRole.writableSigner);
      expect(metas[3].address, systemProgram);
      expect(metas[3].role, AccountRole.readonly);
    });

    test('parses back into the same instruction data', () {
      final parsed = parseCreateCollectionV1Instruction(instruction);

      expect(parsed.name, 'My Collection');
      expect(parsed.uri, 'https://example.com/collection.json');
      expect(parsed.plugins, hasLength(1));

      final plugin = parsed.plugins![0].plugin;
      expect(plugin, isA<PluginRoyalties>());
      final royalties = (plugin as PluginRoyalties).value;
      expect(royalties.basisPoints, 500);
      expect(royalties.creators[0].address, authority);
      expect(royalties.creators[0].percentage, 100);
    });

    test('roundtrips minimal data', () {
      final minimal = getCreateCollectionV1Instruction(
        programAddress: programAddress,
        collection: collection,
        payer: payer,
        systemProgram: systemProgram,
        name: '',
        uri: '',
        plugins: null,
      );

      final parsed = parseCreateCollectionV1Instruction(minimal);

      expect(parsed.name, '');
      expect(parsed.plugins, isNull);
      expect(
        getCreateCollectionV1InstructionDataEncoder().encode(parsed),
        minimal.data,
      );
    });

    test('identifies and parses through the program dispatcher', () {
      expect(
        identifyMplCoreInstruction(instruction.data!),
        MplCoreInstruction.createCollectionV1,
      );

      final parsed = parseMplCoreInstruction(instruction);
      expect(parsed, isA<ParsedCreateCollectionV1>());
      expect(
        (parsed as ParsedCreateCollectionV1).data.name,
        'My Collection',
      );
    });
  });

  group('transferV1', () {
    final compressionProof = CompressionProof(
      owner: asset,
      updateAuthority: const UpdateAuthorityAddress(collection),
      name: 'Compressed Asset',
      uri: 'https://example.com/compressed.json',
      seq: BigInt.from(42),
      plugins: [
        HashablePluginSchema(
          index: BigInt.zero,
          authority: const AuthorityUpdateAuthority(),
          plugin: const PluginImmutableMetadata(ImmutableMetadata()),
        ),
      ],
    );

    final instruction = getTransferV1Instruction(
      programAddress: programAddress,
      asset: asset,
      collection: collection,
      payer: payer,
      authority: authority,
      newOwner: payer,
      systemProgram: systemProgram,
      logWrapper: noopProgram,
      compressionProof: compressionProof,
    );

    test('uses the transferV1 discriminator and program', () {
      expect(instruction.programAddress, programAddress);
      expect(instruction.data![0], 14);
    });

    test('places accounts in the documented order and roles', () {
      final metas = instruction.accounts!;

      expect(metas, hasLength(7));
      expect(metas[0].address, asset);
      expect(metas[0].role, AccountRole.writable);
      expect(metas[1].address, collection);
      expect(metas[1].role, AccountRole.readonly);
      expect(metas[2].address, payer);
      expect(metas[2].role, AccountRole.writableSigner);
      expect(metas[3].address, authority);
      expect(metas[3].role, AccountRole.readonlySigner);
      expect(metas[4].address, payer);
      expect(metas[4].role, AccountRole.readonly);
      expect(metas[5].address, systemProgram);
      expect(metas[5].role, AccountRole.readonly);
      expect(metas[6].address, noopProgram);
      expect(metas[6].role, AccountRole.readonly);
    });

    test('parses back into the same instruction data', () {
      final parsed = parseTransferV1Instruction(instruction);

      expect(parsed.compressionProof, isNotNull);
      final proof = parsed.compressionProof!;
      expect(proof.owner, asset);
      expect(proof.updateAuthority, const UpdateAuthorityAddress(collection));
      expect(proof.name, 'Compressed Asset');
      expect(proof.seq, BigInt.from(42));
      expect(proof.plugins, hasLength(1));

      expect(
        getTransferV1InstructionDataEncoder().encode(parsed),
        instruction.data,
      );
    });

    test('roundtrips a null compression proof', () {
      final minimal = getTransferV1Instruction(
        programAddress: programAddress,
        asset: asset,
        payer: payer,
        newOwner: payer,
        compressionProof: null,
      );

      final parsed = parseTransferV1Instruction(minimal);

      expect(parsed.compressionProof, isNull);
      expect(
        getTransferV1InstructionDataEncoder().encode(parsed),
        minimal.data,
      );
    });

    test('identifies and parses through the program dispatcher', () {
      expect(
        identifyMplCoreInstruction(instruction.data!),
        MplCoreInstruction.transferV1,
      );

      final parsed = parseMplCoreInstruction(instruction);
      expect(parsed, isA<ParsedTransferV1>());
      final proof = (parsed as ParsedTransferV1).data.compressionProof;
      expect(proof, isNotNull);
      expect(proof!.name, 'Compressed Asset');
    });
  });

  group('identifyMplCoreInstruction', () {
    test('throws a SolanaError for unknown data', () {
      expect(
        () => identifyMplCoreInstruction(Uint8List.fromList([0xff, 0xfe])),
        throwsA(isA<SolanaError>()),
      );
    });
  });
}
