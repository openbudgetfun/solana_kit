import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('commitmentComparator', () {
    test(
      'sorts commitments according to their level of finality ascending',
      () {
        final commitments = [
          Commitment.finalized,
          Commitment.processed,
          Commitment.confirmed,
        ]..sort(commitmentComparator);
        expect(commitments, [
          Commitment.processed,
          Commitment.confirmed,
          Commitment.finalized,
        ]);
      },
    );

    test('returns 0 for equal commitments', () {
      expect(
        commitmentComparator(Commitment.confirmed, Commitment.confirmed),
        equals(0),
      );
    });

    test('returns -1 when first is less final', () {
      expect(
        commitmentComparator(Commitment.processed, Commitment.confirmed),
        equals(-1),
      );
    });

    test('returns 1 when first is more final', () {
      expect(
        commitmentComparator(Commitment.finalized, Commitment.confirmed),
        equals(1),
      );
    });
  });
}
