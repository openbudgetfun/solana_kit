import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('isMessagePartialSigner', () {
    test('returns true for MessagePartialSigner', () {
      final signer = MockMessagePartialSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(isMessagePartialSigner(signer), isTrue);
    });

    test('returns false for non-signer', () {
      expect(isMessagePartialSigner('not a signer'), isFalse);
      expect(isMessagePartialSigner(null), isFalse);
    });
  });

  group('assertIsMessagePartialSigner', () {
    test('succeeds for MessagePartialSigner', () {
      final signer = MockMessagePartialSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(() => assertIsMessagePartialSigner(signer), returnsNormally);
    });

    test('throws for non-signer', () {
      expect(
        () => assertIsMessagePartialSigner('not a signer'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerExpectedMessagePartialSigner,
          ),
        ),
      );
    });
  });
}
