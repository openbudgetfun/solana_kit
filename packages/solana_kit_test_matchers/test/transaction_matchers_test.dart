import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('isFullySignedTransactionMatcher', () {
    test('matches a fully signed transaction', () {
      final transaction = createTransactionFixture(
        signature: nonZeroSignatureBytes(1),
      );
      expect(transaction, isFullySignedTransactionMatcher);
    });

    test('does not match a transaction with all-zero signatures', () {
      final transaction = createTransactionFixture(
        signature: SignatureBytes(Uint8List(64)),
      );
      expect(transaction, isNot(isFullySignedTransactionMatcher));
    });

    test('does not match a transaction with null signatures', () {
      final transaction = createTransactionFixture();
      expect(transaction, isNot(isFullySignedTransactionMatcher));
    });

    test('does not match a transaction with no signatures', () {
      final transaction = Transaction(
        messageBytes: Uint8List(32),
        signatures: const {},
      );
      expect(transaction, isNot(isFullySignedTransactionMatcher));
    });

    test('does not match non-Transaction objects', () {
      expect('not a transaction', isNot(isFullySignedTransactionMatcher));
    });
  });

  group('hasSignatureCount', () {
    test('matches when signature count is correct', () {
      final transaction = createTransactionFixture(
        signature: SignatureBytes(Uint8List(64)),
      );
      expect(transaction, hasSignatureCount(1));
    });

    test('does not match when signature count is different', () {
      final transaction = createTransactionFixture(
        signature: SignatureBytes(Uint8List(64)),
      );
      expect(transaction, isNot(hasSignatureCount(2)));
    });
  });
}
