/// Live compatibility contracts for generated upstream program clients.
///
/// Each binary is compiled from the exact source pin used to generate its Dart
/// client. The tests submit ordinary user flows, then decode the resulting
/// program-owned accounts with the same public SDK that built the instructions.
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart' as core;
import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart'
    as metadata;
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_squads/solana_kit_squads.dart' as squads;
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:solana_kit_token/solana_kit_token.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
    await env.deployProgram(
      core.mplCoreProgramAddressObject,
      'config/programs/mpl_core-v0.2.0.so',
    );
    await env.deployProgram(
      metadata.mplTokenMetadataProgramAddressObject,
      'config/programs/mpl_token_metadata-v1.14.0.so',
    );
    await env.deployProgram(
      squads.squadsMultisigProgramAddressObject,
      'config/programs/squads_multisig-v2.1.0.so',
    );
  });

  tearDownAll(() => env.dispose());

  test(
    'pinned upstream artifacts deploy at their canonical addresses',
    () async {
      // A mismatched deployment address makes PDA checks and Anchor's program ID
      // guard fail. All three canonical accounts must therefore be executable.
      for (final address in [
        core.mplCoreProgramAddressObject,
        metadata.mplTokenMetadataProgramAddressObject,
        squads.squadsMultisigProgramAddressObject,
      ]) {
        final response = await env.rpc.getAccountInfoValue(address).send();
        expect(response.value, isNotNull, reason: '$address should exist');
        expect(response.value!['executable'], isTrue);
      }
    },
  );

  test('MPL Core create and transfer match the on-chain account codec', () async {
    // A generated CreateV1 instruction must create an AssetV1 owned by the
    // payer with the exact metadata. TransferV1 must then change only its owner
    // while the public account decoder continues to parse the account.
    final asset = generateKeyPairSigner();
    const name = 'Surfpool Core asset';
    const uri = 'https://example.invalid/core.json';
    await env.sendInstructions(
      [
        core.getCreateV1Instruction(
          programAddress: core.mplCoreProgramAddressObject,
          asset: asset.address,
          payer: env.payer.address,
          owner: env.payer.address,
          updateAuthority: env.payer.address,
          systemProgram: systemProgramAddress,
          dataState: core.DataState.accountState,
          name: name,
          uri: uri,
          plugins: const [],
        ),
      ],
      extraSigners: [asset],
    );

    final created = core.decodeAssetV1(
      await _existingAccount(env, asset.address),
    );
    expect(created.programAddress, core.mplCoreProgramAddressObject);
    expect(created.data.key, core.Key.assetV1);
    expect(created.data.owner, env.payer.address);
    expect(
      created.data.updateAuthority,
      core.UpdateAuthorityAddress(env.payer.address),
    );
    expect(created.data.name, name);
    expect(created.data.uri, uri);

    final newOwner = generateKeyPairSigner().address;
    await env.sendInstructions([
      core.getTransferV1Instruction(
        programAddress: core.mplCoreProgramAddressObject,
        asset: asset.address,
        payer: env.payer.address,
        authority: env.payer.address,
        newOwner: newOwner,
        systemProgram: systemProgramAddress,
        compressionProof: null,
      ),
    ]);

    final transferred = core.decodeAssetV1(
      await _existingAccount(env, asset.address),
    );
    expect(transferred.data.owner, newOwner);
    expect(transferred.data.name, name);
    expect(transferred.data.uri, uri);
  });

  test(
    'Token Metadata creates and updates metadata for an SPL mint',
    () async {
      // This crosses two upstream programs: the SDK first creates a real SPL
      // mint, derives its canonical metadata PDA, creates Metadata, and updates
      // it. The decoded fields prove account ordering and Borsh layouts match.
      final mint = generateKeyPairSigner();
      await env.sendInstructions(
        [
          getCreateAccountInstruction(
            payer: env.payer.address,
            newAccount: mint.address,
            lamports: BigInt.from(1_461_600),
            space: BigInt.from(mintSize),
            programAddress: tokenProgramAddress,
            instructionProgramAddress: systemProgramAddress,
          ),
          getInitializeMint2Instruction(
            programAddress: tokenProgramAddress,
            mint: mint.address,
            decimals: 0,
            mintAuthority: env.payer.address,
          ),
        ],
        extraSigners: [mint],
      );
      final (metadataAddress, _) = await metadata.findMetadataPda(
        mint: mint.address,
      );
      final initialData = metadata.DataV2(
        name: 'Surfpool Metadata',
        symbol: 'SURF',
        uri: 'https://example.invalid/metadata-v1.json',
        sellerFeeBasisPoints: 250,
        creators: [
          metadata.Creator(
            address: env.payer.address,
            verified: true,
            share: 100,
          ),
        ],
        collection: null,
        uses: null,
      );
      await env.sendInstructions([
        metadata.getCreateMetadataAccountV3Instruction(
          programAddress: metadata.mplTokenMetadataProgramAddressObject,
          metadata: metadataAddress,
          mint: mint.address,
          mintAuthority: env.payer.address,
          payer: env.payer.address,
          updateAuthority: env.payer.address,
          systemProgram: systemProgramAddress,
          data: initialData,
          isMutable: true,
          collectionDetails: null,
        ),
      ]);

      final created = metadata.decodeMetadata(
        await _existingAccount(env, metadataAddress),
      );
      expect(
        created.programAddress,
        metadata.mplTokenMetadataProgramAddressObject,
      );
      expect(created.data.mint, mint.address);
      expect(created.data.updateAuthority, env.payer.address);
      // The legacy program intentionally puffs these fields with NUL bytes;
      // the official JavaScript tests apply the same normalization.
      expect(_unpadded(created.data.data.name), initialData.name);
      expect(_unpadded(created.data.data.symbol), initialData.symbol);
      expect(_unpadded(created.data.data.uri), initialData.uri);
      expect(created.data.data.sellerFeeBasisPoints, 250);

      final updatedData = metadata.DataV2(
        name: 'Surfpool Metadata v2',
        symbol: initialData.symbol,
        uri: 'https://example.invalid/metadata-v2.json',
        sellerFeeBasisPoints: initialData.sellerFeeBasisPoints,
        creators: initialData.creators,
        collection: null,
        uses: null,
      );
      await env.sendInstructions([
        metadata.getUpdateMetadataAccountV2Instruction(
          programAddress: metadata.mplTokenMetadataProgramAddressObject,
          metadata: metadataAddress,
          updateAuthority: env.payer.address,
          data: updatedData,
          newUpdateAuthority: null,
          primarySaleHappened: null,
          isMutable: null,
        ),
      ]);

      final updated = metadata.decodeMetadata(
        await _existingAccount(env, metadataAddress),
      );
      expect(_unpadded(updated.data.data.name), updatedData.name);
      expect(_unpadded(updated.data.data.uri), updatedData.uri);
      expect(updated.data.isMutable, isTrue);
    },
  );

  test('Squads creates and expands a multisig using its canonical PDAs', () async {
    // Mainnet initializes ProgramConfig once with a fixed Squads key. The test
    // injects that already-initialized singleton, then exercises public user
    // flows: create a 1-of-1 multisig and add a second member with reallocation.
    final treasury = generateKeyPairSigner().address;
    await env.surfnet.fundSol(treasury, 1_000_000);
    final (programConfig, _) = await squads.findProgramConfigPda();
    final programConfigData = squads.getProgramConfigEncoder().encode(
      squads.ProgramConfig(
        authority: env.payer.address,
        multisigCreationFee: BigInt.zero,
        treasury: treasury,
        reserved: Uint8List(64),
      ),
    );
    await env.surfnet.setAccount(
      programConfig,
      2_000_000,
      programConfigData,
      squads.squadsMultisigProgramAddressObject,
    );

    final createKey = generateKeyPairSigner();
    final (multisigAddress, _) = await squads.findMultisigPda(
      createKey: createKey.address,
    );
    const allPermissions = squads.Permissions(mask: 7);
    await env.sendInstructions(
      [
        squads.getMultisigCreateV2Instruction(
          programAddress: squads.squadsMultisigProgramAddressObject,
          programConfig: programConfig,
          treasury: treasury,
          multisig: multisigAddress,
          createKey: createKey.address,
          creator: env.payer.address,
          systemProgram: systemProgramAddress,
          configAuthority: env.payer.address,
          threshold: 1,
          members: [
            squads.Member(
              key: env.payer.address,
              permissions: allPermissions,
            ),
          ],
          timeLock: 0,
          rentCollector: null,
          memo: 'created by Surfpool compatibility test',
        ),
      ],
      extraSigners: [createKey],
    );

    final created = squads.decodeMultisig(
      await _existingAccount(env, multisigAddress),
    );
    expect(created.programAddress, squads.squadsMultisigProgramAddressObject);
    expect(created.data.createKey, createKey.address);
    expect(created.data.configAuthority, env.payer.address);
    expect(created.data.threshold, 1);
    expect(created.data.members, hasLength(1));

    final secondMember = generateKeyPairSigner().address;
    await env.sendInstructions([
      squads.getMultisigAddMemberInstruction(
        programAddress: squads.squadsMultisigProgramAddressObject,
        multisig: multisigAddress,
        configAuthority: env.payer.address,
        rentPayer: env.payer.address,
        systemProgram: systemProgramAddress,
        newMember: squads.Member(
          key: secondMember,
          permissions: allPermissions,
        ),
        memo: 'add second member',
      ),
    ]);

    final expanded = squads.decodeMultisig(
      await _existingAccount(env, multisigAddress),
    );
    expect(expanded.data.members, hasLength(2));
    expect(
      expanded.data.members.map((member) => member.key),
      containsAll([env.payer.address, secondMember]),
    );
    expect(expanded.data.threshold, 1);
  });
}

Future<EncodedAccount> _existingAccount(
  IntegrationTestEnv env,
  Address address,
) async {
  final account = await fetchEncodedAccount(env.rpc, address);
  expect(account, isA<ExistingAccount<Uint8List>>());
  return (account as ExistingAccount<Uint8List>).account;
}

String _unpadded(String value) => value.replaceAll('\u0000', '');
