import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:test/test.dart';

void main() {
  group('resolveMaxInstructionsPerTransaction', () {
    test('defaults to 16 when no value is provided', () {
      expect(resolveMaxInstructionsPerTransaction(null), 16);
      expect(resolveMaxInstructionsPerTransaction(null), 16);
      expect(defaultMaxInstructionsPerTransaction, 16);
    });

    test('returns a valid provided value as-is', () {
      expect(resolveMaxInstructionsPerTransaction(1), 1);
      expect(resolveMaxInstructionsPerTransaction(42), 42);
      expect(resolveMaxInstructionsPerTransaction(64), 64);
      expect(
        resolveMaxInstructionsPerTransaction(transactionInstructionLimit),
        transactionInstructionLimit,
      );
    });

    test('rejects zero', () {
      expect(
        () => resolveMaxInstructionsPerTransaction(0),
        throwsA(
          isA<SolanaError>()
              .having(
                (e) => e.code,
                'code',
                SolanaErrorCode
                    .instructionPlansInvalidMaxInstructionsPerTransaction,
              )
              .having(
                (e) => e.context,
                'context',
                {
                  'maxInstructions': 0,
                  'transactionInstructionLimit': 64,
                },
              ),
        ),
      );
    });

    test('rejects negative values', () {
      expect(
        () => resolveMaxInstructionsPerTransaction(-1),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .instructionPlansInvalidMaxInstructionsPerTransaction,
          ),
        ),
      );
    });

    test('rejects values greater than the transaction limit', () {
      expect(
        () => resolveMaxInstructionsPerTransaction(65),
        throwsA(
          isA<SolanaError>()
              .having(
                (e) => e.code,
                'code',
                SolanaErrorCode
                    .instructionPlansInvalidMaxInstructionsPerTransaction,
              )
              .having(
                (e) => e.context,
                'context',
                {
                  'maxInstructions': 65,
                  'transactionInstructionLimit': 64,
                },
              ),
        ),
      );
    });
  });

  group('assertMaxInstructionsPerTransaction', () {
    test('passes when the number of instructions is within the maximum', () {
      expect(
        () => assertMaxInstructionsPerTransaction(16, 16),
        returnsNormally,
      );
      expect(() => assertMaxInstructionsPerTransaction(0, 1), returnsNormally);
      expect(() => assertMaxInstructionsPerTransaction(3, 5), returnsNormally);
    });

    test('throws when the number of instructions exceeds the maximum', () {
      expect(
        () => assertMaxInstructionsPerTransaction(17, 16),
        throwsA(
          isA<SolanaError>()
              .having(
                (e) => e.code,
                'code',
                SolanaErrorCode
                    .instructionPlansMaxInstructionsPerTransactionExceeded,
              )
              .having(
                (e) => e.context,
                'context',
                {'maxInstructions': 16, 'numInstructions': 17},
              ),
        ),
      );
    });
  });

  group('assertMessageCanAccommodateSize', () {
    test('passes when the next size is within the limit', () {
      expect(
        () => assertMessageCanAccommodateSize(
          currentSize: 100,
          nextSize: 1232,
          sizeLimit: 1232,
        ),
        returnsNormally,
      );
    });

    test(
      'throws with the required and free bytes when the next size exceeds the limit',
      () {
        expect(
          () => assertMessageCanAccommodateSize(
            currentSize: 1132,
            nextSize: 1282,
            sizeLimit: 1232,
          ),
          throwsA(
            isA<SolanaError>()
                .having(
                  (e) => e.code,
                  'code',
                  SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan,
                )
                .having(
                  (e) => e.context,
                  'context',
                  {'numBytesRequired': 150, 'numFreeBytes': 100},
                ),
          ),
        );
      },
    );
  });

  group('isMessagePackerErrorThatRequiresNewCandidate', () {
    test('returns true for every capacity error', () {
      final errors = <Object>[
        SolanaError(
          SolanaErrorCode.instructionPlansMaxInstructionsPerTransactionExceeded,
          {'maxInstructions': 16, 'numInstructions': 17},
        ),
        SolanaError(
          SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan,
          {'numBytesRequired': 150, 'numFreeBytes': 100},
        ),
        SolanaError(
          SolanaErrorCode.instructionPlansMessageRejectedByPacker,
          {'reason': 'test'},
        ),
        SolanaError(SolanaErrorCode.transactionTooManyAccountAddresses, {
          'actualCount': 65,
          'maxAllowed': 64,
        }),
        SolanaError(SolanaErrorCode.transactionTooManyAccountsInInstruction, {
          'actualCount': 256,
          'instructionIndex': 0,
          'maxAllowed': 255,
        }),
        SolanaError(SolanaErrorCode.transactionTooManyInstructions, {
          'actualCount': 65,
          'maxAllowed': 64,
        }),
        SolanaError(SolanaErrorCode.transactionTooManySignerAddresses, {
          'actualCount': 65,
          'maxAllowed': 64,
        }),
      ];

      for (final error in errors) {
        expect(
          isMessagePackerErrorThatRequiresNewCandidate(error),
          isTrue,
          reason: 'expected true for $error',
        );
      }
    });

    test('returns false for other errors and non-errors', () {
      final nonCandidates = <Object>[
        SolanaError(
          SolanaErrorCode.instructionPlansMessagePackerAlreadyComplete,
        ),
        SolanaError(SolanaErrorCode.instructionPlansEmptyInstructionPlan),
        SolanaError(
          SolanaErrorCode.instructionPlansInvalidMaxInstructionsPerTransaction,
          {'maxInstructions': 65, 'transactionInstructionLimit': 64},
        ),
        Exception('not a Solana error'),
        'a string',
        42,
      ];

      for (final error in nonCandidates) {
        expect(
          isMessagePackerErrorThatRequiresNewCandidate(error),
          isFalse,
          reason: 'expected false for $error',
        );
      }
    });
  });
}
