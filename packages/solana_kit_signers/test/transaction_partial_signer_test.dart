import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('isTransactionPartialSigner', () {
    test('returns true for TransactionPartialSigner', () {
      final signer = MockTransactionPartialSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(isTransactionPartialSigner(signer), isTrue);
    });

    test('returns false for non-signer', () {
      expect(isTransactionPartialSigner('not a signer'), isFalse);
    });
  });

  group('assertIsTransactionPartialSigner', () {
    test('succeeds for TransactionPartialSigner', () {
      final signer = MockTransactionPartialSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(() => assertIsTransactionPartialSigner(signer), returnsNormally);
    });

    test('throws for non-signer', () {
      expect(
        () => assertIsTransactionPartialSigner('not a signer'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerExpectedTransactionPartialSigner,
          ),
        ),
      );
    });
  });
}
