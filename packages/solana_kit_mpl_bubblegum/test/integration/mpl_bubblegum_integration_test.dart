// ignore_for_file: public_member_api_docs
/// Integration tests for mpl-bubblegum compressed NFT operations.
///
/// These tests require a running SurfPool instance at localhost:8899.
/// They are NOT run in CI automatically.
///
/// Run with: dart test test/integration/ --tags integration
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
import 'package:test/test.dart';

/// Default RPC URL for a local SurfPool validator.
// Integration tests use SurfPool at localhost:8899.

void main() {
  group('mpl-bubblegum integration', () {
    group('instruction builders', () {
      test('createTree instruction encodes correctly', () {
        final instruction = getCreateTreeInstruction(
          programAddress: mplBubblegumProgramAddressObject,
          treeAuthority: const Address('11111111111111111111111111111112'),
          merkleTree: const Address('11111111111111111111111111111112'),
          payer: const Address('11111111111111111111111111111112'),
          treeCreator: const Address('11111111111111111111111111111112'),
          logWrapper: const Address('noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK'),
          compressionProgram: const Address('cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi'),
          systemProgram: const Address('11111111111111111111111111111112'),
          maxDepth: 14,
          maxBufferSize: 64,
          public: true,
        );

        expect(instruction.programAddress, equals(mplBubblegumProgramAddressObject));
        expect(instruction.accounts!.length, equals(7));
        expect(instruction.data, isNotNull);
        expect(instruction.data!.length, greaterThan(0));
      });

      test('burn instruction encodes correctly', () {
        final instruction = getBurnInstruction(
          programAddress: mplBubblegumProgramAddressObject,
          treeAuthority: const Address('11111111111111111111111111111112'),
          leafOwner: const Address('11111111111111111111111111111112'),
          leafDelegate: const Address('11111111111111111111111111111112'),
          merkleTree: const Address('11111111111111111111111111111112'),
          logWrapper: const Address('noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK'),
          compressionProgram: const Address('cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi'),
          systemProgram: const Address('11111111111111111111111111111112'),
          root: List.filled(32, 0),
          dataHash: List.filled(32, 0),
          creatorHash: List.filled(32, 0),
          nonce: BigInt.zero,
          index: 0,
        );

        expect(instruction.programAddress, equals(mplBubblegumProgramAddressObject));
        expect(instruction.accounts!.length, equals(7));
      });

      test('transfer instruction encodes correctly', () {
        final instruction = getTransferInstruction(
          programAddress: mplBubblegumProgramAddressObject,
          treeAuthority: const Address('11111111111111111111111111111112'),
          leafOwner: const Address('11111111111111111111111111111112'),
          leafDelegate: const Address('11111111111111111111111111111112'),
          newLeafOwner: const Address('11111111111111111111111111111112'),
          merkleTree: const Address('11111111111111111111111111111112'),
          logWrapper: const Address('noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK'),
          compressionProgram: const Address('cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi'),
          systemProgram: const Address('11111111111111111111111111111112'),
          root: List.filled(32, 0),
          dataHash: List.filled(32, 0),
          creatorHash: List.filled(32, 0),
          nonce: BigInt.zero,
          index: 0,
        );

        expect(instruction.programAddress, equals(mplBubblegumProgramAddressObject));
        expect(instruction.accounts!.length, equals(8));
      });

      test('delegate instruction encodes correctly', () {
        final instruction = getDelegateInstruction(
          programAddress: mplBubblegumProgramAddressObject,
          treeAuthority: const Address('11111111111111111111111111111112'),
          leafOwner: const Address('11111111111111111111111111111112'),
          previousLeafDelegate: const Address('11111111111111111111111111111112'),
          newLeafDelegate: const Address('11111111111111111111111111111112'),
          merkleTree: const Address('11111111111111111111111111111112'),
          logWrapper: const Address('noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK'),
          compressionProgram: const Address('cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi'),
          systemProgram: const Address('11111111111111111111111111111112'),
          root: List.filled(32, 0),
          dataHash: List.filled(32, 0),
          creatorHash: List.filled(32, 0),
          nonce: BigInt.zero,
          index: 0,
        );

        expect(instruction.programAddress, equals(mplBubblegumProgramAddressObject));
        expect(instruction.accounts!.length, equals(8));
      });

      test('mintV1 instruction encodes correctly', () {
        final instruction = getMintV1Instruction(
          programAddress: mplBubblegumProgramAddressObject,
          treeAuthority: const Address('11111111111111111111111111111112'),
          leafOwner: const Address('11111111111111111111111111111112'),
          leafDelegate: const Address('11111111111111111111111111111112'),
          merkleTree: const Address('11111111111111111111111111111112'),
          payer: const Address('11111111111111111111111111111112'),
          treeDelegate: const Address('11111111111111111111111111111112'),
          logWrapper: const Address('noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK'),
          compressionProgram: const Address('cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi'),
          systemProgram: const Address('11111111111111111111111111111112'),
          message: const MetadataArgs(
            name: 'Test NFT',
            uri: 'https://example.com/metadata.json',
            sellerFeeBasisPoints: 0,
            creators: [],
          ),
        );

        expect(instruction.programAddress, equals(mplBubblegumProgramAddressObject));
        expect(instruction.accounts!.length, equals(9));
        expect(instruction.data, isNotNull);
        expect(instruction.data!.length, greaterThan(1));
        // First byte should be discriminator (14)
        expect(instruction.data![0], equals(14));
      });
    });

    group('composite helpers', () {
      test('getCreateTreeInstructionPlan returns valid plan', () {
        final plan = getCreateTreeInstructionPlan(
          const CreateTreeInput(
            merkleTree: Address('11111111111111111111111111111112'),
            payer: Address('11111111111111111111111111111112'),
            treeCreator: Address('11111111111111111111111111111112'),
            maxDepth: 14,
            maxBufferSize: 64,
          ),
        );

        expect(plan, isNotNull);
      });

      test('getBurnInstructionPlan returns valid plan', () {
        final plan = getBurnInstructionPlan(
          BurnInput(
            root: List.filled(32, 0),
            dataHash: List.filled(32, 0),
            creatorHash: List.filled(32, 0),
            nonce: BigInt.zero,
            index: 0,
            leafOwner: const Address('11111111111111111111111111111112'),
            leafDelegate: const Address('11111111111111111111111111111112'),
            merkleTree: const Address('11111111111111111111111111111112'),
          ),
        );

        expect(plan, isNotNull);
      });

      test('getTransferInstructionPlan returns valid plan', () {
        final plan = getTransferInstructionPlan(
          TransferInput(
            root: List.filled(32, 0),
            dataHash: List.filled(32, 0),
            creatorHash: List.filled(32, 0),
            nonce: BigInt.zero,
            index: 0,
            leafOwner: const Address('11111111111111111111111111111112'),
            leafDelegate: const Address('11111111111111111111111111111112'),
            merkleTree: const Address('11111111111111111111111111111112'),
            newLeafOwner: const Address('11111111111111111111111111111112'),
          ),
        );

        expect(plan, isNotNull);
      });

      test('getDelegateInstructionPlan returns valid plan', () {
        final plan = getDelegateInstructionPlan(
          DelegateInput(
            root: List.filled(32, 0),
            dataHash: List.filled(32, 0),
            creatorHash: List.filled(32, 0),
            nonce: BigInt.zero,
            index: 0,
            leafOwner: const Address('11111111111111111111111111111112'),
            previousDelegate: const Address('11111111111111111111111111111112'),
            newDelegate: const Address('11111111111111111111111111111112'),
            merkleTree: const Address('11111111111111111111111111111112'),
          ),
        );

        expect(plan, isNotNull);
      });

      test('getMintV1InstructionPlan returns valid plan', () {
        final plan = getMintV1InstructionPlan(
          const MintV1Input(
            merkleTree: Address('11111111111111111111111111111112'),
            leafOwner: Address('11111111111111111111111111111112'),
            leafDelegate: Address('11111111111111111111111111111112'),
            payer: Address('11111111111111111111111111111112'),
            treeDelegate: Address('11111111111111111111111111111112'),
            name: 'Test NFT',
            uri: 'https://example.com/metadata.json',
          ),
        );

        expect(plan, isNotNull);
      });
    });

    group('DAS API abstraction', () {
      test('DasAssetProof can be created', () {
        const proof = DasAssetProof(
          root: 'abc123',
          proof: ['def456', 'ghi789'],
          nodeIndex: 0,
          leaf: 'jkl012',
          treeId: 'mno345',
        );

        expect(proof.root, equals('abc123'));
        expect(proof.proof.length, equals(2));
      });

      test('AssetWithProof can be created', () {
        const asset = DasAsset(
          id: 'test-id',
          ownership: DasAssetOwnership(frozen: false, nonTransferable: false),
          compression: DasAssetCompression(
            compressed: true,
            dataHash: 'hash1',
            creatorHash: 'hash2',
            assetHash: 'hash3',
            tree: 'tree1',
            seq: 1,
            leafId: 0,
          ),
          content: null,
          creators: [],
          grouping: [],
        );

        const proof = DasAssetProof(
          root: 'root1',
          proof: ['proof1'],
          nodeIndex: 0,
          leaf: 'leaf1',
          treeId: 'tree1',
        );

        final assetWithProof = AssetWithProof(
          rpcAsset: asset,
          rpcAssetProof: proof,
          leafOwner: 'owner1',
          leafDelegate: 'delegate1',
          merkleTree: 'tree1',
          root: Uint8List(32),
          dataHash: Uint8List(32),
          creatorHash: Uint8List(32),
          nonce: BigInt.zero,
          index: 0,
          proof: [Uint8List(32)],
        );

        expect(assetWithProof.rpcAsset.id, equals('test-id'));
        expect(assetWithProof.nonce, equals(BigInt.zero));
      });
    });
  });
}