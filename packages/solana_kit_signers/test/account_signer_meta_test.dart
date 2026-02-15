import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('getSignersFromInstruction', () {
    test('extracts signers from the account metas of the instruction', () {
      final signerA = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final signerB = MockTransactionModifyingSigner(
        const Address('22222222222222222222222222222222'),
      );
      final instruction = createMockInstructionWithSigners([signerA, signerB]);

      final extractedSigners = getSignersFromInstruction(instruction);

      expect(extractedSigners, hasLength(2));
      expect(identical(extractedSigners[0], signerA), isTrue);
      expect(identical(extractedSigners[1], signerB), isTrue);
    });

    test('removes duplicated signers by reference', () {
      final signerA = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final signerB = MockTransactionModifyingSigner(
        const Address('22222222222222222222222222222222'),
      );
      final instruction = createMockInstructionWithSigners([
        signerA,
        signerB,
        signerA,
        signerA,
      ]);

      final extractedSigners = getSignersFromInstruction(instruction);

      expect(extractedSigners, hasLength(2));
    });
  });

  group('getSignersFromTransactionMessage', () {
    test('extracts signers from the account metas of the transaction', () {
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

      final extractedSigners = getSignersFromTransactionMessage(transaction);

      expect(extractedSigners, hasLength(2));
      expect(identical(extractedSigners[0], signerA), isTrue);
      expect(identical(extractedSigners[1], signerB), isTrue);
    });

    test('extracts the fee payer signer of the transaction', () {
      final feePayer = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final transaction = setTransactionMessageFeePayerSigner(
        feePayer,
        createTransactionMessage(version: TransactionVersion.v0),
      );

      final extractedSigners = getSignersFromTransactionMessage(transaction);

      expect(extractedSigners, hasLength(1));
      expect(identical(extractedSigners[0], feePayer), isTrue);
    });

    test('removes duplicated signers', () {
      final signerA = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final signerB = MockTransactionModifyingSigner(
        const Address('22222222222222222222222222222222'),
      );
      final transaction = createMockTransactionMessageWithSigners([
        signerA,
        signerB,
        signerA,
        signerA,
      ]);

      final extractedSigners = getSignersFromTransactionMessage(transaction);

      expect(extractedSigners, hasLength(2));
    });
  });
}
