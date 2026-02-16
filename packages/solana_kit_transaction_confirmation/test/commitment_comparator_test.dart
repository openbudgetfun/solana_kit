import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart'
    as tc;
import 'package:test/test.dart';

void main() {
  group('commitmentComparator', () {
    test('processed < confirmed', () {
      expect(
        tc.commitmentComparator(Commitment.processed, Commitment.confirmed),
        isNegative,
      );
    });

    test('confirmed < finalized', () {
      expect(
        tc.commitmentComparator(Commitment.confirmed, Commitment.finalized),
        isNegative,
      );
    });

    test('processed < finalized', () {
      expect(
        tc.commitmentComparator(Commitment.processed, Commitment.finalized),
        isNegative,
      );
    });

    test('finalized > confirmed', () {
      expect(
        tc.commitmentComparator(Commitment.finalized, Commitment.confirmed),
        isPositive,
      );
    });

    test('confirmed > processed', () {
      expect(
        tc.commitmentComparator(Commitment.confirmed, Commitment.processed),
        isPositive,
      );
    });

    test('same commitment returns 0', () {
      expect(
        tc.commitmentComparator(Commitment.processed, Commitment.processed),
        equals(0),
      );
      expect(
        tc.commitmentComparator(Commitment.confirmed, Commitment.confirmed),
        equals(0),
      );
      expect(
        tc.commitmentComparator(Commitment.finalized, Commitment.finalized),
        equals(0),
      );
    });
  });
}
