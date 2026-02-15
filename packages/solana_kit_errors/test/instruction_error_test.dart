import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('getSolanaErrorFromInstructionError', () {
    test('converts simple string instruction error', () {
      final error = getSolanaErrorFromInstructionError(0, 'GenericError');
      expect(error.code, SolanaErrorCode.instructionErrorGenericError);
      expect(error.context['index'], 0);
    });

    test('converts Custom error with code', () {
      final error = getSolanaErrorFromInstructionError(1, {'Custom': 42});
      expect(error.code, SolanaErrorCode.instructionErrorCustom);
      expect(error.context['code'], 42);
      expect(error.context['index'], 1);
    });

    test('converts InsufficientFunds error', () {
      final error = getSolanaErrorFromInstructionError(2, 'InsufficientFunds');
      expect(error.code, SolanaErrorCode.instructionErrorInsufficientFunds);
      expect(error.context['index'], 2);
    });

    test('converts AccountAlreadyInitialized error', () {
      final error = getSolanaErrorFromInstructionError(
        0,
        'AccountAlreadyInitialized',
      );
      expect(
        error.code,
        SolanaErrorCode.instructionErrorAccountAlreadyInitialized,
      );
    });

    test('converts BorshIoError with context', () {
      final error = getSolanaErrorFromInstructionError(3, {
        'BorshIoError': 'some error message',
      });
      expect(error.code, SolanaErrorCode.instructionErrorBorshIoError);
    });

    test('converts unknown instruction error', () {
      final error = getSolanaErrorFromInstructionError(
        0,
        'SomeNewUnknownError',
      );
      // Unknown errors get code offset -1 from base, which wraps to unknown
      expect(error.context['errorName'], 'SomeNewUnknownError');
    });

    test('passes instruction index in context', () {
      final error = getSolanaErrorFromInstructionError(5, 'InvalidArgument');
      expect(error.context['index'], 5);
    });

    test('converts all known instruction error names', () {
      const knownErrors = [
        'GenericError',
        'InvalidArgument',
        'InvalidInstructionData',
        'InvalidAccountData',
        'AccountDataTooSmall',
        'InsufficientFunds',
        'IncorrectProgramId',
        'MissingRequiredSignature',
        'AccountAlreadyInitialized',
        'UninitializedAccount',
        'UnbalancedInstruction',
        'ModifiedProgramId',
        'ExternalAccountLamportSpend',
        'ExternalAccountDataModified',
        'ReadonlyLamportChange',
        'ReadonlyDataModified',
        'DuplicateAccountIndex',
        'ExecutableModified',
        'RentEpochModified',
        'NotEnoughAccountKeys',
        'AccountDataSizeChanged',
        'AccountNotExecutable',
        'AccountBorrowFailed',
        'AccountBorrowOutstanding',
        'DuplicateAccountOutOfSync',
        'InvalidError',
        'ExecutableDataModified',
        'ExecutableLamportChange',
        'ExecutableAccountNotRentExempt',
        'UnsupportedProgramId',
        'CallDepth',
        'MissingAccount',
        'ReentrancyNotAllowed',
        'MaxSeedLengthExceeded',
        'InvalidSeeds',
        'InvalidRealloc',
        'ComputationalBudgetExceeded',
        'PrivilegeEscalation',
        'ProgramEnvironmentSetupFailure',
        'ProgramFailedToComplete',
        'ProgramFailedToCompile',
        'Immutable',
        'IncorrectAuthority',
        'BorshIoError',
        'AccountNotRentExempt',
        'InvalidAccountOwner',
        'ArithmeticOverflow',
        'UnsupportedSysvar',
        'IllegalOwner',
        'MaxAccountsDataAllocationsExceeded',
        'MaxAccountsExceeded',
        'MaxInstructionTraceLengthExceeded',
        'BuiltinProgramsMustConsumeComputeUnits',
      ];

      for (final errorName in knownErrors) {
        final error = getSolanaErrorFromInstructionError(0, errorName);
        expect(
          error.code,
          greaterThanOrEqualTo(SolanaErrorCode.instructionErrorGenericError),
          reason: 'Error $errorName should have a valid error code',
        );
      }
    });
  });
}
