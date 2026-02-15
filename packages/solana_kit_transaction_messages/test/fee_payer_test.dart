import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  const feePayerA = Address('7mvYAxeCui21xYkAyQSjh6iBVZPpgVyt7PYv9km8V5mE');
  const feePayerB = Address('5LHng8dLBxCYyR3jdDbobLiRQ6pR74pYtxKohY93RbZN');

  group('setTransactionMessageFeePayer', () {
    late TransactionMessage baseTx;

    setUp(() {
      baseTx = createTransactionMessage(version: TransactionVersion.v0);
    });

    test('sets the fee payer on the transaction', () {
      final txWithFeePayer = setTransactionMessageFeePayer(feePayerA, baseTx);
      expect(txWithFeePayer.feePayer, feePayerA);
    });

    group('given a transaction with a fee payer already set', () {
      late TransactionMessage txWithFeePayerA;

      setUp(() {
        txWithFeePayerA = setTransactionMessageFeePayer(feePayerA, baseTx);
      });

      test('sets the new fee payer on the transaction when it differs from '
          'the existing one', () {
        final txWithFeePayerB = setTransactionMessageFeePayer(
          feePayerB,
          txWithFeePayerA,
        );
        expect(txWithFeePayerB.feePayer, feePayerB);
      });

      test('returns the original transaction when trying to set the same '
          'fee payer again', () {
        final txWithSameFeePayer = setTransactionMessageFeePayer(
          feePayerA,
          txWithFeePayerA,
        );
        expect(identical(txWithFeePayerA, txWithSameFeePayer), isTrue);
      });
    });
  });
}
