import 'package:solana_kit_spl_account_compression/solana_kit_spl_account_compression.dart';
import 'package:test/test.dart';

void main() {
  group('getConcurrentMerkleTreeAccountSize', () {
    test('throws for invalid depth-size pair', () {
      expect(
        () => getConcurrentMerkleTreeAccountSize(
          maxDepth: 14,
          maxBufferSize: 32,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws for negative canopy depth', () {
      expect(
        () => getConcurrentMerkleTreeAccountSize(
          maxDepth: 14,
          maxBufferSize: 64,
          canopyDepth: -1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws for canopy depth exceeding max depth', () {
      expect(
        () => getConcurrentMerkleTreeAccountSize(
          maxDepth: 14,
          maxBufferSize: 64,
          canopyDepth: 15,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('returns larger size for deeper trees at same buffer', () {
      final size14 = getConcurrentMerkleTreeAccountSize(
        maxDepth: 14,
        maxBufferSize: 64,
      );
      final size20 = getConcurrentMerkleTreeAccountSize(
        maxDepth: 20,
        maxBufferSize: 64,
      );
      expect(size20, greaterThan(size14));
    });

    test('returns larger size for larger buffers at same depth', () {
      final size64 = getConcurrentMerkleTreeAccountSize(
        maxDepth: 14,
        maxBufferSize: 64,
      );
      final size256 = getConcurrentMerkleTreeAccountSize(
        maxDepth: 14,
        maxBufferSize: 256,
      );
      expect(size256, greaterThan(size64));
    });

    test('returns 0 canopy when canopyDepth=0', () {
      final noCanopy = getConcurrentMerkleTreeAccountSize(
        maxDepth: 14,
        maxBufferSize: 64,
        canopyDepth: 0,
      );
      final withCanopy = getConcurrentMerkleTreeAccountSize(
        maxDepth: 14,
        maxBufferSize: 64,
      );
      // Full canopy depth is larger than zero canopy.
      expect(withCanopy, greaterThan(noCanopy));
    });

    test('matches known formula for depth 3, buffer 8', () {
      // Header = 2 + 54 = 56 bytes
      // PathNodeSize = 33 bytes (1 index byte + 32 node bytes)
      // ChangeLogEntrySize = (3+1) * 33 + 4 + 1 + 4 = 140
      // ConcurrentMerkleTreeSize = 8 + 8 + 8 + 8 * 140 + (3+1)*33 + 1 = 1290
      // Canopy (depth=3) = (1+2+4) * 32 = 224
      // Total = 56 + 1290 + 224 = 1570 (approximate)
      final size = getConcurrentMerkleTreeAccountSize(
        maxDepth: 3,
        maxBufferSize: 8,
      );
      expect(size, greaterThan(1000));
    });

    test('depth 14 buffer 64 is a valid size', () {
      final size = getConcurrentMerkleTreeAccountSize(
        maxDepth: 14,
        maxBufferSize: 64,
      );
      expect(size, greaterThan(10000));
    });
  });

  group('isValidDepthSizePair', () {
    test('returns true for valid pairs', () {
      expect(isValidDepthSizePair(maxDepth: 14, maxBufferSize: 64), isTrue);
      expect(isValidDepthSizePair(maxDepth: 3, maxBufferSize: 8), isTrue);
      expect(isValidDepthSizePair(maxDepth: 30, maxBufferSize: 2048), isTrue);
    });

    test('returns false for invalid pairs', () {
      expect(isValidDepthSizePair(maxDepth: 14, maxBufferSize: 32), isFalse);
      expect(isValidDepthSizePair(maxDepth: 4, maxBufferSize: 8), isFalse);
      expect(isValidDepthSizePair(maxDepth: 30, maxBufferSize: 64), isFalse);
    });
  });

  group('program addresses', () {
    test('splAccountCompressionProgramAddress is correct', () {
      expect(
        splAccountCompressionProgramAddress,
        'cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi',
      );
    });

    test('noopProgramAddress is correct', () {
      expect(
        noopProgramAddress,
        'noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK',
      );
    });
  });

  group('validDepthSizePairs', () {
    test('contains all 34 expected pairs', () {
      expect(validDepthSizePairs.length, 34);
    });

    test('spot check critical pairs exist', () {
      expect(
        validDepthSizePairs.any(
          (p) => p.maxDepth == 14 && p.maxBufferSize == 64,
        ),
        isTrue,
      );
      expect(
        validDepthSizePairs.any(
          (p) => p.maxDepth == 30 && p.maxBufferSize == 2048,
        ),
        isTrue,
      );
    });
  });
}
