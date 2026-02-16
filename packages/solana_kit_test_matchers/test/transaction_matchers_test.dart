import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  const feePayer = Address('E9Nykp3rSdza2moQutaJ3K3RSC8E5iFERX2SqLTsQfjJ');

  group('isFullySignedTransactionMatcher', () {
    test('matches a fully signed transaction', () {
      final sig = Uint8List(64);
      sig[0] = 1; // Non-zero signature.
      final transaction = Transaction(
        messageBytes: Uint8List(32),
        signatures: {feePayer: SignatureBytes(sig)},
      );
      expect(transaction, isFullySignedTransactionMatcher);
    });

    test('does not match a transaction with all-zero signatures', () {
      final transaction = Transaction(
        messageBytes: Uint8List(32),
        signatures: {feePayer: SignatureBytes(Uint8List(64))},
      );
      expect(transaction, isNot(isFullySignedTransactionMatcher));
    });

    test('does not match a transaction with null signatures', () {
      final transaction = Transaction(
        messageBytes: Uint8List(32),
        signatures: {feePayer: null},
      );
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
      final transaction = Transaction(
        messageBytes: Uint8List(32),
        signatures: {feePayer: SignatureBytes(Uint8List(64))},
      );
      expect(transaction, hasSignatureCount(1));
    });

    test('does not match when signature count is different', () {
      final transaction = Transaction(
        messageBytes: Uint8List(32),
        signatures: {feePayer: SignatureBytes(Uint8List(64))},
      );
      expect(transaction, isNot(hasSignatureCount(2)));
    });
  });
}
