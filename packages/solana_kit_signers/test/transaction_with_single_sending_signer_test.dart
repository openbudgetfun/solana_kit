import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('isTransactionMessageWithSingleSendingSigner', () {
    test('returns true if a transaction message contains a single sending only'
        ' signer', () {
      final signer = MockTransactionSendingSigner(
        const Address('22222222222222222222222222222222'),
      );
      final transaction = createMockTransactionMessageWithSigners([signer]);

      expect(isTransactionMessageWithSingleSendingSigner(transaction), isTrue);
    });

    test('returns true if a transaction message contains multiple sending'
        ' signer composites', () {
      final signerA = MockTransactionCompositeSigner(
        const Address('11111111111111111111111111111111'),
      );
      final signerB = MockTransactionCompositeSigner(
        const Address('22222222222222222222222222222222'),
      );
      final transaction = createMockTransactionMessageWithSigners([
        signerA,
        signerB,
      ]);

      expect(isTransactionMessageWithSingleSendingSigner(transaction), isTrue);
    });

    test('returns false if a transaction message contains multiple sending'
        ' only signers', () {
      final signerA = MockTransactionSendingSigner(
        const Address('11111111111111111111111111111111'),
      );
      final signerB = MockTransactionSendingSigner(
        const Address('22222222222222222222222222222222'),
      );
      final transaction = createMockTransactionMessageWithSigners([
        signerA,
        signerB,
      ]);

      expect(isTransactionMessageWithSingleSendingSigner(transaction), isFalse);
    });

    test(
      'returns false if a transaction message contains no sending signer',
      () {
        final signerA = MockTransactionPartialSigner(
          const Address('11111111111111111111111111111111'),
        );
        final signerB = MockTransactionModifyingSigner(
          const Address('22222222222222222222222222222222'),
        );
        final transaction = createMockTransactionMessageWithSigners([
          signerA,
          signerB,
        ]);

        expect(
          isTransactionMessageWithSingleSendingSigner(transaction),
          isFalse,
        );
      },
    );
  });

  group('assertIsTransactionMessageWithSingleSendingSigner', () {
    test('succeeds if a transaction message contains a single sending only'
        ' signer', () {
      final signer = MockTransactionSendingSigner(
        const Address('22222222222222222222222222222222'),
      );
      final transaction = createMockTransactionMessageWithSigners([signer]);

      expect(
        () => assertIsTransactionMessageWithSingleSendingSigner(transaction),
        returnsNormally,
      );
    });

    test('succeeds if a transaction contains multiple sending signer'
        ' composites', () {
      final signerA = MockTransactionCompositeSigner(
        const Address('11111111111111111111111111111111'),
      );
      final signerB = MockTransactionCompositeSigner(
        const Address('22222222222222222222222222222222'),
      );
      final transaction = createMockTransactionMessageWithSigners([
        signerA,
        signerB,
      ]);

      expect(
        () => assertIsTransactionMessageWithSingleSendingSigner(transaction),
        returnsNormally,
      );
    });

    test('fails if a transaction message contains multiple sending only'
        ' signers', () {
      final signerA = MockTransactionSendingSigner(
        const Address('11111111111111111111111111111111'),
      );
      final signerB = MockTransactionSendingSigner(
        const Address('22222222222222222222222222222222'),
      );
      final transaction = createMockTransactionMessageWithSigners([
        signerA,
        signerB,
      ]);

      expect(
        () => assertIsTransactionMessageWithSingleSendingSigner(transaction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerTransactionCannotHaveMultipleSendingSigners,
          ),
        ),
      );
    });

    test(
      'fails if a transaction message contains no sending signer at all',
      () {
        final signerA = MockTransactionPartialSigner(
          const Address('11111111111111111111111111111111'),
        );
        final signerB = MockTransactionModifyingSigner(
          const Address('22222222222222222222222222222222'),
        );
        final transaction = createMockTransactionMessageWithSigners([
          signerA,
          signerB,
        ]);

        expect(
          () => assertIsTransactionMessageWithSingleSendingSigner(transaction),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.signerTransactionSendingSignerMissing,
            ),
          ),
        );
      },
    );
  });
}
