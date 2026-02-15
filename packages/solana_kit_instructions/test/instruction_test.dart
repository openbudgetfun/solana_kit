import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:test/test.dart';

void main() {
  const programAddress = Address('address');

  group('isInstructionForProgram', () {
    test('returns true when the instruction has the given program address', () {
      const instruction = Instruction(programAddress: programAddress);
      expect(isInstructionForProgram(instruction, programAddress), isTrue);
    });

    test('returns false when the instruction does not have the given program '
        'address', () {
      const instruction = Instruction(programAddress: programAddress);
      const otherAddress = Address('abc');
      expect(isInstructionForProgram(instruction, otherAddress), isFalse);
    });
  });

  group('assertIsInstructionForProgram', () {
    test(
      'does not throw when the instruction has the given program address',
      () {
        const instruction = Instruction(programAddress: programAddress);
        expect(
          () => assertIsInstructionForProgram(instruction, programAddress),
          returnsNormally,
        );
      },
    );

    test(
      'throws when the instruction does not have the given program address',
      () {
        const instruction = Instruction(programAddress: programAddress);
        const otherAddress = Address('abc');
        expect(
          () => assertIsInstructionForProgram(instruction, otherAddress),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.instructionProgramIdMismatch,
            ),
          ),
        );
      },
    );
  });

  group('isInstructionWithAccounts', () {
    test('returns true when the instruction has an array of accounts', () {
      const instruction = Instruction(
        programAddress: programAddress,
        accounts: [
          AccountMeta(address: Address('abc'), role: AccountRole.readonly),
        ],
      );
      expect(isInstructionWithAccounts(instruction), isTrue);
    });

    test(
      'returns true when the instruction has an empty array of accounts',
      () {
        const instruction = Instruction(
          programAddress: programAddress,
          accounts: [],
        );
        expect(isInstructionWithAccounts(instruction), isTrue);
      },
    );

    test(
      'returns false when the instruction does not have accounts defined',
      () {
        const instruction = Instruction(programAddress: programAddress);
        expect(isInstructionWithAccounts(instruction), isFalse);
      },
    );
  });

  group('assertIsInstructionWithAccounts', () {
    test('does not throw when the instruction has an array of accounts', () {
      const instruction = Instruction(
        programAddress: programAddress,
        accounts: [
          AccountMeta(address: Address('abc'), role: AccountRole.readonly),
        ],
      );
      expect(
        () => assertIsInstructionWithAccounts(instruction),
        returnsNormally,
      );
    });

    test(
      'does not throw when the instruction has an empty array of accounts',
      () {
        const instruction = Instruction(
          programAddress: programAddress,
          accounts: [],
        );
        expect(
          () => assertIsInstructionWithAccounts(instruction),
          returnsNormally,
        );
      },
    );

    test('throws when the instruction does not have accounts defined', () {
      const instruction = Instruction(programAddress: programAddress);
      expect(
        () => assertIsInstructionWithAccounts(instruction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionExpectedToHaveAccounts,
          ),
        ),
      );
    });
  });

  group('isInstructionWithData', () {
    test('returns true when the instruction has non-empty data', () {
      final instruction = Instruction(
        programAddress: programAddress,
        data: Uint8List.fromList([1, 2, 3, 4]),
      );
      expect(isInstructionWithData(instruction), isTrue);
    });

    test('returns true when the instruction has empty data', () {
      final instruction = Instruction(
        programAddress: programAddress,
        data: Uint8List(0),
      );
      expect(isInstructionWithData(instruction), isTrue);
    });

    test('returns false when the instruction does not have data defined', () {
      const instruction = Instruction(programAddress: programAddress);
      expect(isInstructionWithData(instruction), isFalse);
    });
  });

  group('assertIsInstructionWithData', () {
    test('does not throw when the instruction has non-empty data', () {
      final instruction = Instruction(
        programAddress: programAddress,
        data: Uint8List.fromList([1, 2, 3, 4]),
      );
      expect(() => assertIsInstructionWithData(instruction), returnsNormally);
    });

    test('does not throw when the instruction has empty data', () {
      final instruction = Instruction(
        programAddress: programAddress,
        data: Uint8List(0),
      );
      expect(() => assertIsInstructionWithData(instruction), returnsNormally);
    });

    test('throws when the instruction does not have data defined', () {
      const instruction = Instruction(programAddress: programAddress);
      expect(
        () => assertIsInstructionWithData(instruction),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionExpectedToHaveData,
          ),
        ),
      );
    });
  });
}
