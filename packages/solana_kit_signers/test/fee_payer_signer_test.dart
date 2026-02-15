import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('setTransactionMessageFeePayerSigner', () {
    test('sets the fee payer signer on the transaction', () {
      final feePayer = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final baseTx = createTransactionMessage(version: TransactionVersion.v0);

      final txWithFeePayer = setTransactionMessageFeePayerSigner(
        feePayer,
        baseTx,
      );

      expect(txWithFeePayer, isA<TransactionMessageWithFeePayerSigner>());
      expect(txWithFeePayer.feePayerSigner, equals(feePayer));
      expect(txWithFeePayer.feePayer, equals(feePayer.address));
    });

    test(
      'overrides the fee payer signer when it differs from the existing one',
      () {
        final feePayerA = MockTransactionPartialSigner(
          const Address('11111111111111111111111111111111'),
        );
        final feePayerB = MockTransactionPartialSigner(
          const Address('22222222222222222222222222222222'),
        );
        final baseTx = createTransactionMessage(version: TransactionVersion.v0);

        final txWithFeePayerA = setTransactionMessageFeePayerSigner(
          feePayerA,
          baseTx,
        );
        final txWithFeePayerB = setTransactionMessageFeePayerSigner(
          feePayerB,
          txWithFeePayerA,
        );

        expect(txWithFeePayerB.feePayerSigner, equals(feePayerB));
        expect(txWithFeePayerB.feePayer, equals(feePayerB.address));
      },
    );

    test('overrides the fee payer even when the existing fee payer address is'
        ' the same', () {
      final feePayer = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final baseTx = createTransactionMessage(version: TransactionVersion.v0);

      final txWithFeePayer = setTransactionMessageFeePayerSigner(
        feePayer,
        baseTx,
      );
      final txWithSameFeePayer = setTransactionMessageFeePayerSigner(
        feePayer,
        txWithFeePayer,
      );

      expect(txWithSameFeePayer.feePayerSigner, equals(feePayer));
      expect(identical(txWithSameFeePayer, txWithFeePayer), isFalse);
    });

    test('overrides a non-signer fee payer with a signer fee payer', () {
      final feePayer = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final baseTx = setTransactionMessageFeePayer(
        feePayer.address,
        createTransactionMessage(version: TransactionVersion.v0),
      );

      final txWithFeePayerSigner = setTransactionMessageFeePayerSigner(
        feePayer,
        baseTx,
      );

      expect(txWithFeePayerSigner, isA<TransactionMessageWithFeePayerSigner>());
      expect(txWithFeePayerSigner.feePayerSigner, equals(feePayer));
    });
  });
}
