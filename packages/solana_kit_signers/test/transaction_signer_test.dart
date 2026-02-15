import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('isTransactionSigner', () {
    test('returns true for TransactionPartialSigner', () {
      final signer = MockTransactionPartialSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(isTransactionSigner(signer), isTrue);
    });

    test('returns true for TransactionModifyingSigner', () {
      final signer = MockTransactionModifyingSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(isTransactionSigner(signer), isTrue);
    });

    test('returns true for TransactionSendingSigner', () {
      final signer = MockTransactionSendingSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(isTransactionSigner(signer), isTrue);
    });

    test('returns false for non-signer', () {
      expect(isTransactionSigner('not a signer'), isFalse);
    });
  });

  group('assertIsTransactionSigner', () {
    test('succeeds for TransactionPartialSigner', () {
      final signer = MockTransactionPartialSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(() => assertIsTransactionSigner(signer), returnsNormally);
    });

    test('succeeds for TransactionModifyingSigner', () {
      final signer = MockTransactionModifyingSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(() => assertIsTransactionSigner(signer), returnsNormally);
    });

    test('succeeds for TransactionSendingSigner', () {
      final signer = MockTransactionSendingSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(() => assertIsTransactionSigner(signer), returnsNormally);
    });

    test('throws for non-signer', () {
      expect(
        () => assertIsTransactionSigner('not a signer'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerExpectedTransactionSigner,
          ),
        ),
      );
    });
  });
}
