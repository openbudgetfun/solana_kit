import 'dart:typed_data';

import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';
import 'package:test/test.dart';

void main() {
  group('Merkle proof security', () {
    final leaf = Uint8List.fromList(List.filled(32, 1));
    final sibling = Uint8List.fromList(List.filled(32, 2));
    final tree = MerkleTree([leaf, sibling], 1);

    test('accepts the committed leaf position', () {
      expect(
        MerkleTree.verify(
          root: tree.getRoot(),
          leaf: leaf,
          leafIndex: 0,
          proof: [sibling],
        ),
        isTrue,
      );
    });

    for (final leafIndex in [-2, 2, 4, 0x100000000]) {
      test('rejects replaying a proof at index $leafIndex', () {
        expect(
          MerkleTree.verify(
            root: tree.getRoot(),
            leaf: leaf,
            leafIndex: leafIndex,
            proof: [sibling],
          ),
          isFalse,
          reason: 'A depth-one proof only commits to indices 0 and 1.',
        );
      });
    }

    test('rejects malformed zero-depth commitments', () {
      for (final length in [0, 1, 31, 33, 64]) {
        final malformedNode = Uint8List(length);
        expect(
          MerkleTree.verify(
            root: malformedNode,
            leaf: malformedNode,
            leafIndex: 0,
            proof: const [],
          ),
          isFalse,
          reason: 'Hash nodes must be exactly 32 bytes.',
        );
      }
    });

    test('rejects reinterpreting a parent as a variable-width leaf', () {
      final combinedChildren = Uint8List.fromList([...leaf, ...sibling]);
      final emptySibling = Uint8List(0);
      expect(
        MerkleTree.verify(
          root: tree.getRoot(),
          leaf: combinedChildren,
          leafIndex: 0,
          proof: [emptySibling],
        ),
        isFalse,
        reason: 'Concatenating malformed nodes must not forge leaf membership.',
      );
    });

    test('rejects a malformed sibling with a correctly sized leaf', () {
      expect(
        MerkleTree.verify(
          root: tree.getRoot(),
          leaf: leaf,
          leafIndex: 0,
          proof: [Uint8List(31)],
        ),
        isFalse,
      );
    });

    test('accepts the second position and a depth-zero leaf', () {
      expect(
        MerkleTree.verify(
          root: tree.getRoot(),
          leaf: sibling,
          leafIndex: 1,
          proof: [leaf],
        ),
        isTrue,
      );
      expect(
        MerkleTree.verify(
          root: leaf,
          leaf: leaf,
          leafIndex: 0,
          proof: const [],
        ),
        isTrue,
      );
    });
  });
}
