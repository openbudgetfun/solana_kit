import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('isTransactionSendingSigner', () {
    test('returns true for TransactionSendingSigner', () {
      final signer = MockTransactionSendingSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(isTransactionSendingSigner(signer), isTrue);
    });

    test('returns false for non-signer', () {
      expect(isTransactionSendingSigner('not a signer'), isFalse);
    });
  });

  group('assertIsTransactionSendingSigner', () {
    test('succeeds for TransactionSendingSigner', () {
      final signer = MockTransactionSendingSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(() => assertIsTransactionSendingSigner(signer), returnsNormally);
    });

    test('throws for non-signer', () {
      expect(
        () => assertIsTransactionSendingSigner('not a signer'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerExpectedTransactionSendingSigner,
          ),
        ),
      );
    });
  });
}
