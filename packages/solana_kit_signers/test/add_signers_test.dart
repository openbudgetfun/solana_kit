import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('addSignersToInstruction', () {
    test('adds signers to the account metas of the instruction', () {
      final instruction = Instruction(
        programAddress: const Address(
          '9999999999999999999999999999999999999999999',
        ),
        accounts: [
          const AccountMeta(
            address: Address('11111111111111111111111111111111'),
            role: AccountRole.readonlySigner,
          ),
          const AccountMeta(
            address: Address('22222222222222222222222222222222'),
            role: AccountRole.writableSigner,
          ),
        ],
        data: Uint8List(0),
      );

      final signerA = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final signerB = MockTransactionModifyingSigner(
        const Address('22222222222222222222222222222222'),
      );

      final instructionWithSigners = addSignersToInstruction([
        signerA,
        signerB,
      ], instruction);

      expect(instructionWithSigners.accounts, hasLength(2));
      expect(instructionWithSigners.accounts![0], isA<AccountSignerMeta>());
      expect(instructionWithSigners.accounts![1], isA<AccountSignerMeta>());
      expect(
        (instructionWithSigners.accounts![0] as AccountSignerMeta).signer,
        equals(signerA),
      );
      expect(
        (instructionWithSigners.accounts![1] as AccountSignerMeta).signer,
        equals(signerB),
      );
    });

    test('ignores account metas that already have a signer', () {
      final signerA = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final instruction = Instruction(
        programAddress: const Address(
          '9999999999999999999999999999999999999999999',
        ),
        accounts: [
          AccountSignerMeta(
            address: const Address('11111111111111111111111111111111'),
            role: AccountRole.readonlySigner,
            signer: signerA,
          ),
        ],
        data: Uint8List(0),
      );

      final signerB = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final instructionWithSigners = addSignersToInstruction([
        signerB,
      ], instruction);

      // The original signer A should remain.
      expect(
        identical(
          (instructionWithSigners.accounts![0] as AccountSignerMeta).signer,
          signerA,
        ),
        isTrue,
      );
    });

    test('ignores account metas that do not have a signer role', () {
      final instruction = Instruction(
        programAddress: const Address(
          '9999999999999999999999999999999999999999999',
        ),
        accounts: [
          const AccountMeta(
            address: Address('11111111111111111111111111111111'),
            role: AccountRole.writable,
          ),
        ],
        data: Uint8List(0),
      );

      final signer = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final instructionWithSigners = addSignersToInstruction([
        signer,
      ], instruction);

      expect(
        instructionWithSigners.accounts![0],
        isNot(isA<AccountSignerMeta>()),
      );
    });

    test('can add the same signer to multiple account metas', () {
      final instruction = Instruction(
        programAddress: const Address(
          '9999999999999999999999999999999999999999999',
        ),
        accounts: [
          const AccountMeta(
            address: Address('11111111111111111111111111111111'),
            role: AccountRole.readonlySigner,
          ),
          const AccountMeta(
            address: Address('11111111111111111111111111111111'),
            role: AccountRole.writableSigner,
          ),
        ],
        data: Uint8List(0),
      );

      final signer = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final instructionWithSigners = addSignersToInstruction([
        signer,
      ], instruction);

      expect(instructionWithSigners.accounts![0], isA<AccountSignerMeta>());
      expect(instructionWithSigners.accounts![1], isA<AccountSignerMeta>());
    });

    test('fails if two distinct signers are provided for the same address', () {
      final instruction = Instruction(
        programAddress: const Address(
          '9999999999999999999999999999999999999999999',
        ),
        accounts: [
          const AccountMeta(
            address: Address('11111111111111111111111111111111'),
            role: AccountRole.readonlySigner,
          ),
        ],
        data: Uint8List(0),
      );

      final signerA = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final signerB = MockTransactionModifyingSigner(
        const Address('11111111111111111111111111111111'),
      );

      expect(
        () => addSignersToInstruction([signerA, signerB], instruction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.signerAddressCannotHaveMultipleSigners,
          ),
        ),
      );
    });

    test('returns the instruction as-is if it has no account metas', () {
      final instruction = Instruction(
        programAddress: const Address(
          '9999999999999999999999999999999999999999999',
        ),
        accounts: const [],
        data: Uint8List(0),
      );

      final instructionWithSigners = addSignersToInstruction([], instruction);

      expect(identical(instructionWithSigners, instruction), isTrue);
    });
  });

  group('addSignersToTransactionMessage', () {
    test('adds signers to the account metas of the transaction', () {
      final instructionA = Instruction(
        programAddress: const Address(
          '8888888888888888888888888888888888888888888',
        ),
        accounts: [
          const AccountMeta(
            address: Address('11111111111111111111111111111111'),
            role: AccountRole.readonlySigner,
          ),
        ],
        data: Uint8List(0),
      );
      final instructionB = Instruction(
        programAddress: const Address(
          '9999999999999999999999999999999999999999999',
        ),
        accounts: [
          const AccountMeta(
            address: Address('22222222222222222222222222222222'),
            role: AccountRole.writableSigner,
          ),
        ],
        data: Uint8List(0),
      );
      final transaction = TransactionMessage(
        version: TransactionVersion.v0,
        instructions: [instructionA, instructionB],
      );

      final signerA = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final signerB = MockTransactionModifyingSigner(
        const Address('22222222222222222222222222222222'),
      );

      final transactionWithSigners = addSignersToTransactionMessage([
        signerA,
        signerB,
      ], transaction);

      expect(
        transactionWithSigners.instructions[0].accounts![0],
        isA<AccountSignerMeta>(),
      );
      expect(
        transactionWithSigners.instructions[1].accounts![0],
        isA<AccountSignerMeta>(),
      );
    });

    test('returns the transaction as-is if it has no instructions or fee payer'
        ' to update', () {
      const transaction = TransactionMessage(version: TransactionVersion.v0);

      final signer = MockTransactionPartialSigner(
        const Address('11111111111111111111111111111111'),
      );
      final transactionWithSigners = addSignersToTransactionMessage([
        signer,
      ], transaction);

      expect(identical(transactionWithSigners, transaction), isTrue);
    });
  });
}
