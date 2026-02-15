import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_programs/solana_kit_programs.dart';
import 'package:test/test.dart';

void main() {
  group('isProgramError', () {
    test('identifies an error as a custom program error', () {
      // Given a transaction message with a single instruction.
      const programAddress = Address('1111');
      const transactionMessage = TransactionMessageInput(
        instructions: {0: InstructionInput(programAddress: programAddress)},
      );

      // And a custom program error on the instruction.
      final error = SolanaError(SolanaErrorCode.instructionErrorCustom, {
        'code': 42,
        'index': 0,
      });

      // Then we expect the error to be identified as a program error.
      expect(isProgramError(error, transactionMessage, programAddress), isTrue);
    });

    test('matches the provided custom program error code', () {
      // Given a transaction message with a single instruction.
      const programAddress = Address('1111');
      const transactionMessage = TransactionMessageInput(
        instructions: {0: InstructionInput(programAddress: programAddress)},
      );

      // And a custom program error with code 42.
      final error = SolanaError(SolanaErrorCode.instructionErrorCustom, {
        'code': 42,
        'index': 0,
      });

      // When we specify the custom program error code 42.
      final result = isProgramError(
        error,
        transactionMessage,
        programAddress,
        42,
      );

      // Then we expect the result to be true.
      expect(result, isTrue);
    });

    test('returns false if the program address does not match', () {
      // Given a transaction message with a program A instruction.
      const programA = Address('1111');
      const transactionMessage = TransactionMessageInput(
        instructions: {0: InstructionInput(programAddress: programA)},
      );

      // And a custom program error on the instruction.
      final error = SolanaError(SolanaErrorCode.instructionErrorCustom, {
        'code': 42,
        'index': 0,
      });

      // When we try to identify the error as a program error for program B.
      const programB = Address('2222');
      final result = isProgramError(error, transactionMessage, programB);

      // Then we expect the result to be false.
      expect(result, isFalse);
    });

    test(
      'returns false if instruction index is missing from error context',
      () {
        // Given a transaction message with a single instruction.
        const programAddress = Address('1111');
        const transactionMessage = TransactionMessageInput(
          instructions: {0: InstructionInput(programAddress: programAddress)},
        );

        // And a custom program error pointing to a missing instruction.
        final error = SolanaError(SolanaErrorCode.instructionErrorCustom, {
          'code': 42,
          'index': 999,
        });

        // Then we expect the error not to be identified as a program error.
        expect(
          isProgramError(error, transactionMessage, programAddress),
          isFalse,
        );
      },
    );

    test('returns false if custom program error code does not match', () {
      // Given a transaction message with a single instruction.
      const programAddress = Address('1111');
      const transactionMessage = TransactionMessageInput(
        instructions: {0: InstructionInput(programAddress: programAddress)},
      );

      // And a custom program error on the instruction with code 42.
      final error = SolanaError(SolanaErrorCode.instructionErrorCustom, {
        'code': 42,
        'index': 0,
      });

      // When we try to identify the error as a program error with code 43.
      final result = isProgramError(
        error,
        transactionMessage,
        programAddress,
        43,
      );

      // Then we expect the result to be false.
      expect(result, isFalse);
    });
  });
}
