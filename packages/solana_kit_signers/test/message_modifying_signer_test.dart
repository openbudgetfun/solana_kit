import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('isMessageModifyingSigner', () {
    test('returns true for MessageModifyingSigner', () {
      final signer = MockMessageModifyingSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(isMessageModifyingSigner(signer), isTrue);
    });

    test('returns false for non-signer', () {
      expect(isMessageModifyingSigner('not a signer'), isFalse);
      expect(isMessageModifyingSigner(null), isFalse);
    });
  });

  group('assertIsMessageModifyingSigner', () {
    test('succeeds for MessageModifyingSigner', () {
      final signer = MockMessageModifyingSigner(
        const Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy'),
      );
      expect(() => assertIsMessageModifyingSigner(signer), returnsNormally);
    });

    test('throws for non-signer', () {
      expect(
        () => assertIsMessageModifyingSigner('not a signer'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerExpectedMessageModifyingSigner,
          ),
        ),
      );
    });
  });
}
