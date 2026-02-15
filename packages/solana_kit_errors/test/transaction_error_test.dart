import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('getSolanaErrorFromTransactionError', () {
    test('converts simple string transaction error', () {
      final error = getSolanaErrorFromTransactionError('AccountInUse');
      expect(error.code, SolanaErrorCode.transactionErrorAccountInUse);
    });

    test('converts BlockhashNotFound error', () {
      final error = getSolanaErrorFromTransactionError('BlockhashNotFound');
      expect(error.code, SolanaErrorCode.transactionErrorBlockhashNotFound);
    });

    test('converts DuplicateInstruction with index', () {
      final error = getSolanaErrorFromTransactionError({
        'DuplicateInstruction': 3,
      });
      expect(error.code, SolanaErrorCode.transactionErrorDuplicateInstruction);
      expect(error.context['index'], 3);
    });

    test('converts InsufficientFundsForRent with account index', () {
      final error = getSolanaErrorFromTransactionError({
        'InsufficientFundsForRent': {'account_index': 5},
      });
      expect(
        error.code,
        SolanaErrorCode.transactionErrorInsufficientFundsForRent,
      );
      expect(error.context['accountIndex'], 5);
    });

    test('delegates InstructionError to instruction error handler', () {
      final error = getSolanaErrorFromTransactionError({
        'InstructionError': [0, 'InsufficientFunds'],
      });
      expect(error.code, SolanaErrorCode.instructionErrorInsufficientFunds);
      expect(error.context['index'], 0);
    });

    test('handles InstructionError with Custom error', () {
      final error = getSolanaErrorFromTransactionError({
        'InstructionError': [
          2,
          {'Custom': 99},
        ],
      });
      expect(error.code, SolanaErrorCode.instructionErrorCustom);
      expect(error.context['code'], 99);
      expect(error.context['index'], 2);
    });

    test('converts unknown transaction error', () {
      final error = getSolanaErrorFromTransactionError('UnknownFutureError');
      expect(error.context['errorName'], 'UnknownFutureError');
    });

    test('converts all known transaction error names', () {
      const knownErrors = [
        'AccountInUse',
        'AccountLoadedTwice',
        'AccountNotFound',
        'ProgramAccountNotFound',
        'InsufficientFundsForFee',
        'InvalidAccountForFee',
        'AlreadyProcessed',
        'BlockhashNotFound',
        'CallChainTooDeep',
        'MissingSignatureForFee',
        'InvalidAccountIndex',
        'SignatureFailure',
        'InvalidProgramForExecution',
        'SanitizeFailure',
        'ClusterMaintenance',
        'AccountBorrowOutstanding',
        'WouldExceedMaxBlockCostLimit',
        'UnsupportedVersion',
      ];

      for (final errorName in knownErrors) {
        final error = getSolanaErrorFromTransactionError(errorName);
        expect(
          error.code,
          greaterThanOrEqualTo(SolanaErrorCode.transactionErrorAccountInUse),
          reason: 'Error $errorName should have a valid error code',
        );
      }
    });
  });
}
