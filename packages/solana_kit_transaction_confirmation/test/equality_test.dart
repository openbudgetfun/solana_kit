import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:test/test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // SignatureStatus
  // ---------------------------------------------------------------------------
  group('SignatureStatus equality', () {
    const confirmed = SignatureStatus(
      confirmationStatus: Commitment.confirmed,
    );
    const confirmedCopy = SignatureStatus(
      confirmationStatus: Commitment.confirmed,
    );
    const finalized = SignatureStatus(
      confirmationStatus: Commitment.finalized,
    );
    const withErr = SignatureStatus(
      confirmationStatus: Commitment.confirmed,
      err: 'TransactionExpiredBlockheightExceededError',
    );
    const noStatus = SignatureStatus();

    test('equal when all fields match', () {
      expect(confirmed, equals(confirmedCopy));
    });

    test('hashCode matches for equal instances', () {
      expect(confirmed.hashCode, equals(confirmedCopy.hashCode));
    });

    test('identical instance equals itself', () {
      expect(confirmed, equals(confirmed));
    });

    test('not equal when confirmationStatus differs', () {
      expect(confirmed, isNot(equals(finalized)));
    });

    test('not equal when err differs (null vs non-null)', () {
      expect(confirmed, isNot(equals(withErr)));
    });

    test('not equal when confirmationStatus is null vs non-null', () {
      expect(confirmed, isNot(equals(noStatus)));
    });

    test('equal when both have null fields', () {
      const a = SignatureStatus();
      const b = SignatureStatus();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal with matching err values', () {
      const a = SignatureStatus(
        confirmationStatus: Commitment.processed,
        err: 42,
      );
      const b = SignatureStatus(
        confirmationStatus: Commitment.processed,
        err: 42,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when err values differ', () {
      const a = SignatureStatus(err: 'error1');
      const b = SignatureStatus(err: 'error2');
      expect(a, isNot(equals(b)));
    });

    test('not equal to a different type', () {
      expect(confirmed, isNot(equals('confirmed')));
    });

    test('toString contains fields', () {
      expect(confirmed.toString(), contains('SignatureStatus'));
      expect(confirmed.toString(), contains('confirmed'));
    });
  });
}
