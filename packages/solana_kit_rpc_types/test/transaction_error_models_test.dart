import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('InstructionError models', () {
    test('custom variant exposes label and code', () {
      const error = InstructionErrorCustom(7012);
      expect(error.label, 'Custom');
      expect(error.code, 7012);
    });

    test('simple variant stores label directly', () {
      const error = InstructionErrorSimple('InvalidInstructionData');
      expect(error.label, 'InvalidInstructionData');
    });

    test('known labels remain available', () {
      expect(InstructionErrorLabel.genericError, 'GenericError');
      expect(
        InstructionErrorLabel.computationalBudgetExceeded,
        'ComputationalBudgetExceeded',
      );
      expect(
        InstructionErrorLabel.maxInstructionTraceLengthExceeded,
        'MaxInstructionTraceLengthExceeded',
      );
    });
  });

  group('TransactionError models', () {
    test('simple variant stores label directly', () {
      const error = TransactionErrorSimple('AccountInUse');
      expect(error.label, 'AccountInUse');
    });

    test('DuplicateInstruction variant stores index and label', () {
      const error = TransactionErrorDuplicateInstruction(2);
      expect(error.label, 'DuplicateInstruction');
      expect(error.instructionIndex, 2);
    });

    test('InstructionError variant stores nested instruction error', () {
      const nested = InstructionErrorSimple('InvalidArgument');
      const error = TransactionErrorInstructionError(5, nested);
      expect(error.label, 'InstructionError');
      expect(error.instructionIndex, 5);
      expect(error.instructionError, nested);
    });

    test('InsufficientFundsForRent variant stores account index', () {
      const error = TransactionErrorInsufficientFundsForRent(7);
      expect(error.label, 'InsufficientFundsForRent');
      expect(error.accountIndex, 7);
    });

    test('ProgramExecutionTemporarilyRestricted stores account index', () {
      const error = TransactionErrorProgramExecutionTemporarilyRestricted(9);
      expect(error.label, 'ProgramExecutionTemporarilyRestricted');
      expect(error.accountIndex, 9);
    });

    test('known transaction labels remain available', () {
      expect(TransactionErrorLabel.accountInUse, 'AccountInUse');
      expect(TransactionErrorLabel.blockhashNotFound, 'BlockhashNotFound');
      expect(
        TransactionErrorLabel.wouldExceedMaxVoteCostLimit,
        'WouldExceedMaxVoteCostLimit',
      );
    });
  });
}
