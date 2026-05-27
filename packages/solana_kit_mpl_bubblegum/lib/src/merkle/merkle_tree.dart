/// Merkle tree construction and proof verification for compressed NFTs.
///
/// Provides a simple [MerkleTree] implementation using Keccak-256 hashing,
/// matching the on-chain program's tree structure. This is used for
/// off-chain proof generation and verification of compressed NFT data.
///
/// The tree pads leaves with zero nodes to fill all `2^depth` positions,
/// matching the on-chain concurrent Merkle tree behavior.
library;

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

/// The size of a hash node in bytes (Keccak-256 output).
const nodeSize = 32;

/// A node in the Merkle tree.
final class _MerkleNode {

  _MerkleNode(this.hash, {this.left, this.right});
  final Uint8List hash;
  final _MerkleNode? left;
  final _MerkleNode? right;
}

/// A sparse Merkle tree using Keccak-256 hashing, compatible with the
/// on-chain concurrent Merkle tree used by SPL Account Compression.
///
/// This implementation follows the same hashing scheme as the on-chain
/// program: parent nodes are computed as `keccak256(left || right)`,
/// and empty nodes at depth `d` are `keccak256(emptyNode(d-1) || emptyNode(d-1))`
/// with `emptyNode(0) = zeros(32)`.
class MerkleTree {

  /// Creates a Merkle tree from the given [leaves] with the specified
  /// [depth].
  ///
  /// If [leaves] contains fewer than `2^depth` entries, the remaining
  /// positions are filled with zero (empty) nodes. This matches the
  /// behavior of the on-chain concurrent Merkle tree.
  MerkleTree(List<Uint8List> leaves, this.depth) : _leaves = List.of(leaves) {
    _root = _buildTree(_leaves, depth);
  }
  /// The depth of the tree.
  final int depth;

  /// The root node.
  late final _MerkleNode _root;

  /// The leaves of the tree.
  final List<Uint8List> _leaves;

  /// Returns the root hash of the tree.
  Uint8List getRoot() => _root.hash;

  /// Verifies a Merkle proof.
  ///
  /// Returns `true` if the [leaf] at [leafIndex] with the given [proof]
  /// hashes up to the expected [root].
  static bool verify({
    required Uint8List root,
    required Uint8List leaf,
    required int leafIndex,
    required List<Uint8List> proof,
  }) {
    var computedHash = leaf;
    for (var i = 0; i < proof.length; i++) {
      if ((leafIndex >> i) & 1 == 0) {
        computedHash = keccak256(
          Uint8List.fromList([...computedHash, ...proof[i]]),
        );
      } else {
        computedHash = keccak256(
          Uint8List.fromList([...proof[i], ...computedHash]),
        );
      }
    }
    return _bytesEqual(computedHash, root);
  }

  _MerkleNode _buildTree(List<Uint8List> leaves, int depth) {
    final maxLeaves = 1 << depth;
    final paddedLeaves = List<Uint8List>.filled(maxLeaves, Uint8List(nodeSize));
    for (var i = 0; i < leaves.length && i < maxLeaves; i++) {
      paddedLeaves[i] = leaves[i];
    }

    var currentLevel = <_MerkleNode>[];
    for (var i = 0; i < paddedLeaves.length; i++) {
      final nodeHash = paddedLeaves[i];
      currentLevel.add(
        nodeHash.every((b) => b == 0)
            ? _MerkleNode(computeEmptyNode(0))
            : _MerkleNode(nodeHash),
      );
    }

    // Build empty node cache
    final emptyNodes = <int, Uint8List>{};
    emptyNodes[0] = Uint8List(nodeSize);
    for (var i = 1; i <= depth; i++) {
      emptyNodes[i] = keccak256(
        Uint8List.fromList([...emptyNodes[i - 1]!, ...emptyNodes[i - 1]!]),
      );
    }

    for (var level = 0; level < depth; level++) {
      final nextLevel = <_MerkleNode>[];
      for (var i = 0; i < currentLevel.length; i += 2) {
        final left = currentLevel[i];
        final right = i + 1 < currentLevel.length
            ? currentLevel[i + 1]
            : _MerkleNode(emptyNodes[level + 1]!);
        final parentHash = keccak256(
          Uint8List.fromList([...left.hash, ...right.hash]),
        );
        nextLevel.add(_MerkleNode(parentHash, left: left, right: right));
      }
      currentLevel = nextLevel;
    }

    return currentLevel.single;
  }

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Computes the empty node hash for the given [level] in a Merkle tree.
///
/// An empty node at level 0 is 32 zero bytes.
/// An empty node at level `d` is `keccak256(emptyNode(d-1) || emptyNode(d-1))`.
Uint8List computeEmptyNode(int level) {
  if (level == 0) {
    return Uint8List(nodeSize);
  }
  final child = computeEmptyNode(level - 1);
  return keccak256(Uint8List.fromList([...child, ...child]));
}
