import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('isMessageSigner', () {
    test('returns true for MessagePartialSigner', () {
      final signer = MockMessagePartialSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(isMessageSigner(signer), isTrue);
    });

    test('returns true for MessageModifyingSigner', () {
      final signer = MockMessageModifyingSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(isMessageSigner(signer), isTrue);
    });

    test('returns false for non-signer', () {
      expect(isMessageSigner('not a signer'), isFalse);
    });
  });

  group('assertIsMessageSigner', () {
    test('succeeds for MessagePartialSigner', () {
      final signer = MockMessagePartialSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(() => assertIsMessageSigner(signer), returnsNormally);
    });

    test('succeeds for MessageModifyingSigner', () {
      final signer = MockMessageModifyingSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(() => assertIsMessageSigner(signer), returnsNormally);
    });

    test('throws for non-signer', () {
      expect(
        () => assertIsMessageSigner('not a signer'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerExpectedMessageSigner,
          ),
        ),
      );
    });
  });
}
