import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('isTransactionModifyingSigner', () {
    test('returns true for TransactionModifyingSigner', () {
      final signer = MockTransactionModifyingSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(isTransactionModifyingSigner(signer), isTrue);
    });

    test('returns false for non-signer', () {
      expect(isTransactionModifyingSigner('not a signer'), isFalse);
    });
  });

  group('assertIsTransactionModifyingSigner', () {
    test('succeeds for TransactionModifyingSigner', () {
      final signer = MockTransactionModifyingSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(() => assertIsTransactionModifyingSigner(signer), returnsNormally);
    });

    test('throws for non-signer', () {
      expect(
        () => assertIsTransactionModifyingSigner('not a signer'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerExpectedTransactionModifyingSigner,
          ),
        ),
      );
    });
  });
}
