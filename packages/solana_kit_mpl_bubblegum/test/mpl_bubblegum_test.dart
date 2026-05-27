import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
import 'package:test/test.dart';

void main() {
  group('canTransfer', () {
    test('returns true when not frozen and not nonTransferable', () {
      expect(
        canTransfer(frozen: false, nonTransferable: false),
        isTrue,
      );
    });

    test('returns false when frozen', () {
      expect(
        canTransfer(frozen: true, nonTransferable: false),
        isFalse,
      );
    });

    test('returns false when nonTransferable', () {
      expect(
        canTransfer(frozen: false, nonTransferable: true),
        isFalse,
      );
    });

    test('returns false when both frozen and nonTransferable', () {
      expect(
        canTransfer(frozen: true, nonTransferable: true),
        isFalse,
      );
    });
  });

  group('LeafSchemaV2Flags', () {
    test('none has value 0', () {
      expect(LeafSchemaV2Flags.none.value, 0);
    });

    test('hasCollection has value 1', () {
      expect(LeafSchemaV2Flags.hasCollection.value, 1);
    });

    test('hasAssetData has value 2', () {
      expect(LeafSchemaV2Flags.hasAssetData.value, 2);
    });

    test('hasCollectionAndAssetData has value 3', () {
      expect(LeafSchemaV2Flags.hasCollectionAndAssetData.value, 3);
    });

    test('none has all flags false', () {
      const flags = LeafSchemaV2Flags.none;
      expect(flags.hasCollectionFlag, isFalse);
      expect(flags.hasAssetDataFlag, isFalse);
    });

    test('hasCollection flag getter works', () {
      const flags = LeafSchemaV2Flags.hasCollection;
      expect(flags.hasCollectionFlag, isTrue);
      expect(flags.hasAssetDataFlag, isFalse);
    });

    test('hasAssetData flag getter works', () {
      const flags = LeafSchemaV2Flags.hasAssetData;
      expect(flags.hasCollectionFlag, isFalse);
      expect(flags.hasAssetDataFlag, isTrue);
    });

    test('hasCollectionAndAssetData has both flags', () {
      const flags = LeafSchemaV2Flags.hasCollectionAndAssetData;
      expect(flags.hasCollectionFlag, isTrue);
      expect(flags.hasAssetDataFlag, isTrue);
    });

    test('values list contains all flags', () {
      expect(LeafSchemaV2Flags.values.length, 4);
      expect(LeafSchemaV2Flags.values, contains(LeafSchemaV2Flags.none));
      expect(
          LeafSchemaV2Flags.values, contains(LeafSchemaV2Flags.hasCollection));
      expect(
          LeafSchemaV2Flags.values, contains(LeafSchemaV2Flags.hasAssetData));
      expect(LeafSchemaV2Flags.values,
          contains(LeafSchemaV2Flags.hasCollectionAndAssetData));
    });
  });

  group('MerkleTree', () {
    test('computes root for a single leaf', () {
      final leaf = Uint8List.fromList(List.filled(32, 1));
      final tree = MerkleTree([leaf], 1);
      final root = tree.getRoot();
      expect(root.length, 32);
    });

    test('computes root for two leaves at depth 2', () {
      final leaf1 = Uint8List.fromList(List.filled(32, 1));
      final leaf2 = Uint8List.fromList(List.filled(32, 2));
      final tree = MerkleTree([leaf1, leaf2], 2);
      final root = tree.getRoot();
      expect(root.length, 32);
    });

    test('verify returns true for valid proof', () {
      final leaf = Uint8List.fromList(List.filled(32, 42));
      final emptyNode = Uint8List(32);
      final root = keccak256(
        Uint8List.fromList([...leaf, ...emptyNode]),
      );
      final proof = <Uint8List>[emptyNode];

      expect(
        MerkleTree.verify(
          root: root,
          leaf: leaf,
          leafIndex: 0,
          proof: proof,
        ),
        isTrue,
      );
    });

    test('verify returns false for incorrect leaf', () {
      final leaf = Uint8List.fromList(List.filled(32, 1));
      final wrongLeaf = Uint8List.fromList(List.filled(32, 2));
      final emptyNode = Uint8List(32);
      final root = keccak256(
        Uint8List.fromList([...leaf, ...emptyNode]),
      );
      final proof = <Uint8List>[emptyNode];

      expect(
        MerkleTree.verify(
          root: root,
          leaf: wrongLeaf,
          leafIndex: 0,
          proof: proof,
        ),
        isFalse,
      );
    });
  });

  group('keccak256', () {
    test('distinguishes from SHA3-256', () {
      // Keccak-256("") != SHA3-256("")
      final result = keccak256(Uint8List(0));
      // SHA3-256("") = a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a
      // Keccak-256("") = c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
      const sha3OfEmpty =
          'a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a';
      final resultHex =
          result.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      expect(resultHex, isNot(equals(sha3OfEmpty)));
    });

    test('empty string matches known vector', () {
      final result = keccak256(Uint8List(0));
      final hex =
          result.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      expect(
        hex,
        'c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470',
      );
    });
  });

  group('hashLeafV1', () {
    test('produces 32-byte hash', () {
      final leafAssetId = Uint8List(32);
      const owner = Address('11111111111111111111111111111111');
      final metadataHash = Uint8List(32);

      final hash = hashLeafV1(
        leafAssetId: leafAssetId,
        owner: owner,
        leafIndex: 0,
        metadataHash: metadataHash,
      );
      expect(hash.length, 32);
    });

    test('uses owner as delegate when delegate is null', () {
      final leafAssetId = Uint8List(32);
      const owner = Address('11111111111111111111111111111111');
      final metadataHash = Uint8List(32);

      final withDelegate = hashLeafV1(
        leafAssetId: leafAssetId,
        owner: owner,
        delegate: owner,
        leafIndex: 0,
        metadataHash: metadataHash,
      );

      final withoutDelegate = hashLeafV1(
        leafAssetId: leafAssetId,
        owner: owner,
        leafIndex: 0,
        metadataHash: metadataHash,
      );

      expect(withDelegate, equals(withoutDelegate));
    });
  });

  group('hashLeafV2', () {
    test('produces 32-byte hash', () {
      final leafAssetId = Uint8List(32);
      const owner = Address('11111111111111111111111111111111');
      final metadataHash = Uint8List(32);
      const flags = LeafSchemaV2Flags.hasCollection;

      final hash = hashLeafV2(
        leafAssetId: leafAssetId,
        owner: owner,
        leafIndex: 0,
        metadataHashV2: metadataHash,
        flags: flags,
      );
      expect(hash.length, 32);
    });

    test('includes collection hash when collection is provided', () {
      final leafAssetId = Uint8List(32);
      // Use a valid Solana address (System Program)
      const owner = Address('11111111111111111111111111111112');
      final metadataHash = Uint8List(32);
      const flags = LeafSchemaV2Flags.hasCollection;

      final withCollection = hashLeafV2(
        leafAssetId: leafAssetId,
        owner: owner,
        leafIndex: 0,
        metadataHashV2: metadataHash,
        flags: flags,
        // Use another valid address for collection
        collection: const Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
      );

      final withoutCollection = hashLeafV2(
        leafAssetId: leafAssetId,
        owner: owner,
        leafIndex: 0,
        metadataHashV2: metadataHash,
        flags: flags,
      );

      // Different collection presence produces different hashes
      expect(withCollection, isNot(equals(withoutCollection)));
    });
  });

  group('hashCollection', () {
    test('produces 32-byte hash from a valid address', () {
      // Use a valid Solana address
      const collection = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      final hash = hashCollection(collection);
      expect(hash.length, 32);
    });
  });

  group('hashAssetData', () {
    test('returns keccak256 of empty input when null', () {
      final hash = hashAssetData(null);
      final expected = keccak256(Uint8List(0));
      expect(hash, equals(expected));
    });

    test('returns keccak256 of the input when provided', () {
      final data = Uint8List.fromList([1, 2, 3, 4]);
      final hash = hashAssetData(data);
      final expected = keccak256(data);
      expect(hash, equals(expected));
    });

    test('returns keccak256 of empty input when empty list', () {
      final hash = hashAssetData(Uint8List(0));
      final expected = keccak256(Uint8List(0));
      expect(hash, equals(expected));
    });
  });

  group('computeEmptyNode', () {
    test('depth 0 returns 32 zero bytes', () {
      final node = computeEmptyNode(0);
      expect(node.length, 32);
      expect(node.every((b) => b == 0), isTrue);
    });

    test('depth 1 returns keccak256(zeros || zeros)', () {
      final node1 = computeEmptyNode(1);
      final zeros = Uint8List(32);
      final expected = keccak256(
        Uint8List.fromList([...zeros, ...zeros]),
      );
      expect(node1, equals(expected));
    });

    test('depth 2 returns keccak256(emptyNode1 || emptyNode1)', () {
      final node2 = computeEmptyNode(2);
      final node1 = computeEmptyNode(1);
      final expected = keccak256(
        Uint8List.fromList([...node1, ...node1]),
      );
      expect(node2, equals(expected));
    });
  });

  group('Program addresses', () {
    test('mplBubblegumProgramAddress is correct', () {
      expect(
        mplBubblegumProgramAddress,
        'BGUMAp9Gph7G9Jn2tU58R5L2qPG1Mj9HP7G3G7VYV2Ma',
      );
    });

    test('tokenMetadataProgramAddress is correct', () {
      expect(
        tokenMetadataProgramAddress,
        'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s',
      );
    });
  });


}
