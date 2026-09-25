/// On-chain integration tests for the MPL Bubblegum program client against
/// SurfPool.
///
/// The compiled Bubblegum, SPL Account Compression, and Noop programs (`.so`,
/// pinned to their reference commits) are committed under `config/programs/`
/// and deployed to SurfPool at their canonical addresses by this suite.
///
/// The main test exercises the full compressed-NFT lifecycle on-chain:
/// `createTree` → `mintV1` → `transfer` → `burn`. The merkle-tree account is
/// sized using the account-compression layout formulas
/// (`2 + 54 + treeSize + canopySize` with
/// `treeSize = 24 + bufferSize * (32 * maxDepth + 40) + (32 * maxDepth + 40)`
/// and `canopySize = (2^(canopyDepth + 1) - 2) * 32`), which is required for
/// the deployed Bubblegum binary to accept the tree.
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart'
    hide systemProgramAddress;
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart'
    show GetAccountInfoConfig, getMinimumBalanceForRentExemptionParams;
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart'
    hide TransactionVersion;
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:test/test.dart';

/// Parses the on-chain ConcurrentMerkleTree account and returns the current
/// root, the merkle proof (path nodes) for the most recent change log, and
/// the leaf index.
///
/// Account layout (account-compression v0.3.x):
///   header: 2 (discriminator+version) + 54 (V1 header) = 56 bytes
///   tree:   sequence(8) + activeIndex(8) + bufferSize(8) = 24 bytes
///   changeLogs: [root(32) + pathNodes(32*maxDepth) + index(4) + padding(4)]
///   rightMostPath: [proof(32*maxDepth) + leaf(32) + index(4) + padding(4)]
({List<int> root, List<int> proof, int index}) parseTreeState(
  Uint8List bytes, {
  required int maxDepth,
  required int maxBufferSize,
}) {
  const headerSize = 2 + 54;
  const treePrefixSize = 8 + 8 + 8; // sequence + activeIndex + bufferSize
  final changeLogSize = 32 + 32 * maxDepth + 4 + 4;

  // activeIndex is a u64 LE at headerSize + 8.
  final activeIndex = ByteData.sublistView(
    bytes,
    headerSize + 8,
    headerSize + 16,
  ).getUint64(0, Endian.little);
  final changeLogOffset =
      headerSize + treePrefixSize + activeIndex * changeLogSize;

  final root = bytes.sublist(changeLogOffset, changeLogOffset + 32);
  final proof = bytes.sublist(
    changeLogOffset + 32,
    changeLogOffset + 32 + 32 * maxDepth,
  );
  final index = ByteData.sublistView(
    bytes,
    changeLogOffset + 32 + 32 * maxDepth,
    changeLogOffset + 32 + 32 * maxDepth + 4,
  ).getUint32(0, Endian.little);

  return (root: root, proof: proof, index: index);
}

/// Computes the Bubblegum `data_hash`:
/// `keccak256(keccak256(metadata.try_to_vec()) || seller_fee_basis_points.to_le_bytes())`.
Uint8List computeDataHash(MetadataArgs metadata) {
  final metadataHash = keccak256(encodeMetadataArgs(metadata));
  final sfbp = ByteData(2)
    ..setUint16(0, metadata.sellerFeeBasisPoints, Endian.little);
  return keccak256(
    Uint8List.fromList([...metadataHash, ...sfbp.buffer.asUint8List()]),
  );
}

/// Computes the Bubblegum `creator_hash`:
/// `keccak256(concat(creators.map(c => address || verified || share)))`.
Uint8List computeCreatorHash(List<Creator> creators) {
  final addressEncoder = getAddressEncoder();
  final creatorBytes = <int>[];
  for (final creator in creators) {
    creatorBytes
      ..addAll(addressEncoder.encode(creator.address))
      ..add(creator.verified ? 1 : 0)
      ..add(creator.share);
  }
  return keccak256(Uint8List.fromList(creatorBytes));
}

void main() {
  late IntegrationTestEnv env;

  // Canonical program IDs baked into the deployed binaries (also shipped by
  // `solana_kit_address_constants`).
  const bubblegumProgram = Address(
    'BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY',
  );
  const compressionProgram = Address(
    'cmtDvXumGCrqC1Age74AVPhSRVXJMd8PJS91L8KbNCK',
  );
  const noopProgram = Address(
    'noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV',
  );

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
    await env.deployProgram(
      bubblegumProgram,
      'config/programs/mpl_bubblegum-v0.12.0.so',
    );
    await env.deployProgram(
      compressionProgram,
      'config/programs/spl_account_compression-v0.3.3.so',
    );
    await env.deployProgram(noopProgram, 'config/programs/noop-v0.2.0.so');
  });

  tearDownAll(() => env.dispose());

  test(
    'bubblegum and its CPI programs deploy as executable programs',
    () async {
      for (final program in [
        bubblegumProgram,
        compressionProgram,
        noopProgram,
      ]) {
        final account = await env.rpc.getAccountInfoValue(program).send();
        expect(account.value, isNotNull, reason: '$program should be deployed');
        expect(account.value!['executable'], equals(true));
        expect(
          account.value!['owner'],
          equals('BPFLoaderUpgradeab1e11111111111111111111111'),
        );
      }
    },
  );

  test(
    'createTree, mintV1, transfer, and burn succeed on-chain',
    () async {
      // (maxDepth, maxBufferSize) = (14, 64) with no canopy.
      // accountSize = 2 + 54 + treeSize + canopySize where
      //   treeSize = 24 + 64 * (32*14 + 40) + (32*14 + 40) = 31744
      //   canopySize = 0
      // => 31800 bytes.
      const maxDepth = 14;
      const maxBufferSize = 64;
      const accountSpace = 31800;

      final merkleTree = generateKeyPairSigner();
      final (treeAuthority, _) = await getProgramDerivedAddress(
        seeds: [getAddressEncoder().encode(merkleTree.address)],
        programAddress: bubblegumProgram,
      );

      // 1. Create the zeroed merkle-tree account (rent-exempt), owned by the
      //    account-compression program.
      final rent = await env.rpc
          .request<BigInt>(
            'getMinimumBalanceForRentExemption',
            getMinimumBalanceForRentExemptionParams(BigInt.from(accountSpace)),
          )
          .send();

      await env.sendInstructions(
        [
          getCreateAccountInstruction(
            instructionProgramAddress: systemProgramAddress,
            payer: env.payer.address,
            newAccount: merkleTree.address,
            lamports: rent,
            space: BigInt.from(accountSpace),
            programAddress: compressionProgram,
          ),
        ],
        extraSigners: [merkleTree],
      );

      // 2. createTree.
      await env.sendInstructions([
        getCreateTreeInstruction(
          programAddress: bubblegumProgram,
          treeAuthority: treeAuthority,
          merkleTree: merkleTree.address,
          payer: env.payer.address,
          treeCreator: env.payer.address,
          logWrapper: noopProgram,
          compressionProgram: compressionProgram,
          systemProgram: systemProgramAddress,
          maxDepth: maxDepth,
          maxBufferSize: maxBufferSize,
          public: true,
        ),
      ]);

      // 3. Mint a compressed NFT to leafOwner.
      final leafOwner = generateKeyPairSigner();
      final metadata = MetadataArgs(
        name: 'Test NFT',
        symbol: 'TST',
        uri: 'https://example.com/nft.json',
        sellerFeeBasisPoints: 500,
        creators: [
          Creator(
            address: env.payer.address,
            verified: true,
            share: 100,
          ),
        ],
      );
      await env.sendInstructions([
        getMintV1Instruction(
          programAddress: bubblegumProgram,
          treeAuthority: treeAuthority,
          leafOwner: leafOwner.address,
          leafDelegate: leafOwner.address,
          merkleTree: merkleTree.address,
          payer: env.payer.address,
          treeDelegate: env.payer.address,
          logWrapper: noopProgram,
          compressionProgram: compressionProgram,
          systemProgram: systemProgramAddress,
          message: metadata,
        ),
      ]);

      // 4. Read the tree state: root + proof + index.
      final treeAccount = await env.rpc
          .getAccountInfoValue(
            merkleTree.address,
            const GetAccountInfoConfig(encoding: AccountEncoding.base64),
          )
          .send();
      final data = treeAccount.value!['data']! as List;
      final treeBytes = base64Decode(data[0] as String);
      final treeState = parseTreeState(
        treeBytes,
        maxDepth: maxDepth,
        maxBufferSize: maxBufferSize,
      );
      final dataHash = computeDataHash(metadata);
      final creatorHash = computeCreatorHash(metadata.creators);
      final nonce = BigInt.from(treeState.index);

      // 5. Transfer to a new owner (leafOwner must sign).
      final newOwner = generateKeyPairSigner();
      await env.sendInstructions(
        [
          getTransferInstruction(
            programAddress: bubblegumProgram,
            treeAuthority: treeAuthority,
            leafOwner: leafOwner.address,
            leafDelegate: leafOwner.address,
            newLeafOwner: newOwner.address,
            merkleTree: merkleTree.address,
            logWrapper: noopProgram,
            compressionProgram: compressionProgram,
            systemProgram: systemProgramAddress,
            root: treeState.root,
            dataHash: dataHash,
            creatorHash: creatorHash,
            nonce: nonce,
            index: treeState.index,
          ),
        ],
        extraSigners: [leafOwner],
      );

      // 6. Re-read the tree state (transfer changed the root).
      final treeAccount2 = await env.rpc
          .getAccountInfoValue(
            merkleTree.address,
            const GetAccountInfoConfig(encoding: AccountEncoding.base64),
          )
          .send();
      final data2 = treeAccount2.value!['data']! as List;
      final treeBytes2 = base64Decode(data2[0] as String);
      final treeState2 = parseTreeState(
        treeBytes2,
        maxDepth: maxDepth,
        maxBufferSize: maxBufferSize,
      );

      // 7. Burn (the new owner must sign).
      await env.sendInstructions(
        [
          getBurnInstruction(
            programAddress: bubblegumProgram,
            treeAuthority: treeAuthority,
            leafOwner: newOwner.address,
            leafDelegate: newOwner.address,
            merkleTree: merkleTree.address,
            logWrapper: noopProgram,
            compressionProgram: compressionProgram,
            systemProgram: systemProgramAddress,
            root: treeState2.root,
            dataHash: dataHash,
            creatorHash: creatorHash,
            nonce: nonce,
            index: treeState2.index,
          ),
        ],
        extraSigners: [newOwner],
      );
    },
  );
}
