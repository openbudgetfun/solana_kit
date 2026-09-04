import 'package:solana_kit_spl_account_compression/solana_kit_spl_account_compression.dart';
import 'package:test/test.dart';

void main() {
  group('SPL account compression wire-layout sizes', () {
    // Independent fixtures from the upstream Beet serializers:
    // src/types/ConcurrentMerkleTree.ts, Path.ts, and Canopy.ts.
    for (final fixture in [
      (depth: 3, buffer: 8, canopy: 0, bytes: 1304),
      (depth: 3, buffer: 8, canopy: 1, bytes: 1368),
      (depth: 3, buffer: 8, canopy: 3, bytes: 1752),
      (depth: 14, buffer: 64, canopy: 0, bytes: 31800),
      (depth: 14, buffer: 64, canopy: 10, bytes: 97272),
      (depth: 30, buffer: 2048, canopy: 0, bytes: 2049080),
    ]) {
      test('matches upstream layout $fixture', () {
        expect(
          getConcurrentMerkleTreeAccountSize(
            maxDepth: fixture.depth,
            maxBufferSize: fixture.buffer,
            canopyDepth: fixture.canopy,
          ),
          fixture.bytes,
        );
      });
    }

    test('omitted canopy allocates no cached nodes', () {
      expect(
        getConcurrentMerkleTreeAccountSize(maxDepth: 14, maxBufferSize: 64),
        31800,
      );
    });
  });
}
