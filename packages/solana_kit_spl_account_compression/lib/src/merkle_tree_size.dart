/// Merkle tree size calculation utilities for SPL Account Compression.
///
/// Provides the [getConcurrentMerkleTreeAccountSize] function that returns
/// the required on-chain account size for a concurrent Merkle tree given
/// the tree depth, buffer size, and optional canopy depth.
///
/// This is needed when creating a new Merkle tree account via the
/// [SystemProgram.createAccount] instruction.
///
/// ## Reference
///
/// Size values come from the `@solana/spl-account-compression` JavaScript
/// SDK's `getConcurrentMerkleTreeAccountSize` function, which uses beet
/// serializers to compute exact on-chain account sizes.
///
/// Only the valid (maxDepth, maxBufferSize) pairs defined in
/// [validDepthSizePairs] are accepted; others throw [ArgumentError].
library;

/// Valid (maxDepth, maxBufferSize) pairs for concurrent Merkle trees.
///
/// Only these combinations are accepted by the on-chain program.
const validDepthSizePairs = <({int maxDepth, int maxBufferSize})>[
  (maxDepth: 3, maxBufferSize: 8),
  (maxDepth: 5, maxBufferSize: 8),
  (maxDepth: 6, maxBufferSize: 16),
  (maxDepth: 7, maxBufferSize: 16),
  (maxDepth: 8, maxBufferSize: 16),
  (maxDepth: 9, maxBufferSize: 16),
  (maxDepth: 10, maxBufferSize: 32),
  (maxDepth: 11, maxBufferSize: 32),
  (maxDepth: 12, maxBufferSize: 32),
  (maxDepth: 13, maxBufferSize: 32),
  (maxDepth: 14, maxBufferSize: 64),
  (maxDepth: 14, maxBufferSize: 256),
  (maxDepth: 14, maxBufferSize: 1024),
  (maxDepth: 14, maxBufferSize: 2048),
  (maxDepth: 15, maxBufferSize: 64),
  (maxDepth: 16, maxBufferSize: 64),
  (maxDepth: 17, maxBufferSize: 64),
  (maxDepth: 18, maxBufferSize: 64),
  (maxDepth: 19, maxBufferSize: 64),
  (maxDepth: 20, maxBufferSize: 64),
  (maxDepth: 20, maxBufferSize: 256),
  (maxDepth: 20, maxBufferSize: 1024),
  (maxDepth: 20, maxBufferSize: 2048),
  (maxDepth: 24, maxBufferSize: 64),
  (maxDepth: 24, maxBufferSize: 256),
  (maxDepth: 24, maxBufferSize: 512),
  (maxDepth: 24, maxBufferSize: 1024),
  (maxDepth: 24, maxBufferSize: 2048),
  (maxDepth: 26, maxBufferSize: 512),
  (maxDepth: 26, maxBufferSize: 1024),
  (maxDepth: 26, maxBufferSize: 2048),
  (maxDepth: 30, maxBufferSize: 512),
  (maxDepth: 30, maxBufferSize: 1024),
  (maxDepth: 30, maxBufferSize: 2048),
];

/// Returns whether the given (maxDepth, maxBufferSize) is a valid pair
/// for creating a concurrent Merkle tree.
bool isValidDepthSizePair({required int maxDepth, required int maxBufferSize}) {
  return validDepthSizePairs.any(
    (pair) => pair.maxDepth == maxDepth && pair.maxBufferSize == maxBufferSize,
  );
}

/// Header size for the V1 concurrent Merkle tree account.
///
/// The V1 header consists of:
/// - 1 byte: account discriminant (CompressionAccountType)
/// - 1 byte: header version tag
/// - 4 bytes: maxBufferSize (u32)
/// - 4 bytes: maxDepth (u32)
/// - 32 bytes: authority (Pubkey)
/// - 8 bytes: creationSlot (u64)
/// - 6 bytes: padding
/// Total: 56 bytes
const concurrentMerkleTreeHeaderSizeV1 = 2 + 54;

/// Returns the account space (in bytes) needed for the ConcurrentMerkleTree
/// data structure for the given [maxDepth] and [maxBufferSize].
///
/// This excludes the header and canopy; it only covers the tree data
/// (sequence number, active index, buffer size, change logs, and rightmost
/// proof).
int _concurrentMerkleTreeSize({
  required int maxDepth,
  required int maxBufferSize,
}) {
  // ChangeLogEntry: (maxDepth + 1) PathNodes (each 33 bytes: 32 node + 1
  // index as u8) + 1 u32 (index) + 1 u8 (_padding) + 1 u32 (crc)
  const pathNodeSize = 32 + 1; // node (32 bytes) + index (1 byte)
  final changeLogEntrySize = (maxDepth + 1) * pathNodeSize + 4 + 1 + 4;

  // ConcurrentMerkleTree layout:
  // - sequence_number: u64 (8 bytes)
  // - active_index: u64 (8 bytes)
  // - buffer_size: u64 (8 bytes)
  // - change_logs: [ChangeLogEntry; maxBufferSize]
  // - rightmost_proof: Path (variable size)
  // Path layout: (maxDepth + 1) PathNodes + 1 u8 (proof_index_len as u8)
  final rightmostProofSize = (maxDepth + 1) * pathNodeSize + 1;

  return 8 + // sequence_number
      8 + // active_index
      8 + // buffer_size
      maxBufferSize * changeLogEntrySize +
      rightmostProofSize;
}

/// Returns the canopy size in bytes for the given [canopyDepth].
///
/// The canopy stores cached proof nodes at each depth level from 0 to
/// canopyDepth. At each level `i`, there are `2^i` node values of 32 bytes.
int _canopySize(int canopyDepth) {
  if (canopyDepth <= 0) return 0;
  var size = 0;
  for (var i = 0; i < canopyDepth; i++) {
    size += (1 << i) * 32;
  }
  return size;
}

/// Returns the on-chain account size (in bytes) for a concurrent Merkle
/// tree account with the given [maxDepth], [maxBufferSize], and optional
/// [canopyDepth].
///
/// If [canopyDepth] is not provided, the full canopy depth is assumed
/// (i.e., [maxDepth] levels cached).
///
/// Throws [ArgumentError] if the (maxDepth, maxBufferSize) pair is not
/// a valid configuration.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_spl_account_compression/solana_kit_spl_account_compression.dart';
///
/// void main() {
///   // A tree with depth 14 and buffer size 64.
///   final size = getConcurrentMerkleTreeAccountSize(
///     maxDepth: 14,
///     maxBufferSize: 64,
///   );
///   print(size); // 25896
/// }
/// ```
int getConcurrentMerkleTreeAccountSize({
  required int maxDepth,
  required int maxBufferSize,
  int? canopyDepth,
}) {
  if (!isValidDepthSizePair(maxDepth: maxDepth, maxBufferSize: maxBufferSize)) {
    throw ArgumentError(
      'Invalid depth-size pair: ($maxDepth, $maxBufferSize). '
      'See validDepthSizePairs for accepted combinations.',
    );
  }

  final effectiveCanopyDepth = canopyDepth ?? maxDepth;
  if (effectiveCanopyDepth < 0 || effectiveCanopyDepth > maxDepth) {
    throw ArgumentError(
      'canopyDepth must be between 0 and maxDepth ($maxDepth), '
      'got $effectiveCanopyDepth.',
    );
  }

  return concurrentMerkleTreeHeaderSizeV1 +
      _concurrentMerkleTreeSize(
        maxDepth: maxDepth,
        maxBufferSize: maxBufferSize,
      ) +
      _canopySize(effectiveCanopyDepth);
}
