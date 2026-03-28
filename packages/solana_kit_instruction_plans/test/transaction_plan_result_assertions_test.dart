import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  // Helpers to reduce verbosity.
  SuccessfulSingleTransactionPlanResult makeSuccess() {
    final msg = createMessage();
    final sig = Signature('sig'.padRight(64, '0'));
    return successfulSingleTransactionPlanResult(msg, {'signature': sig});
  }

  FailedSingleTransactionPlanResult makeFailed() =>
      failedSingleTransactionPlanResult(createMessage(), Exception('err'));

  CanceledSingleTransactionPlanResult makeCanceled() =>
      canceledSingleTransactionPlanResult(createMessage());

  SequentialTransactionPlanResult makeSeq() =>
      sequentialTransactionPlanResult([]);

  SequentialTransactionPlanResult makeNonDivSeq() =>
      nonDivisibleSequentialTransactionPlanResult([]);

  ParallelTransactionPlanResult makePar() =>
      parallelTransactionPlanResult([]);

  // ---------------------------------------------------------------------------
  // assertIsSuccessfulSingleTransactionPlanResult
  // ---------------------------------------------------------------------------
  group('assertIsSuccessfulSingleTransactionPlanResult', () {
    test('does nothing for a successful result', () {
      expect(
        () => assertIsSuccessfulSingleTransactionPlanResult(makeSuccess()),
        returnsNormally,
      );
    });

    test('throws for a failed single result with status in actualKind', () {
      expect(
        () => assertIsSuccessfulSingleTransactionPlanResult(makeFailed()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a canceled single result with status in actualKind', () {
      expect(
        () => assertIsSuccessfulSingleTransactionPlanResult(makeCanceled()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a sequential result using kind as actualKind', () {
      expect(
        () => assertIsSuccessfulSingleTransactionPlanResult(makeSeq()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a parallel result using kind as actualKind', () {
      expect(
        () => assertIsSuccessfulSingleTransactionPlanResult(makePar()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // assertIsFailedSingleTransactionPlanResult
  // ---------------------------------------------------------------------------
  group('assertIsFailedSingleTransactionPlanResult', () {
    test('does nothing for a failed result', () {
      expect(
        () => assertIsFailedSingleTransactionPlanResult(makeFailed()),
        returnsNormally,
      );
    });

    test('throws for a successful single result with status in actualKind', () {
      expect(
        () => assertIsFailedSingleTransactionPlanResult(makeSuccess()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a canceled single result with status in actualKind', () {
      expect(
        () => assertIsFailedSingleTransactionPlanResult(makeCanceled()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a sequential result using kind as actualKind', () {
      expect(
        () => assertIsFailedSingleTransactionPlanResult(makeSeq()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a parallel result using kind as actualKind', () {
      expect(
        () => assertIsFailedSingleTransactionPlanResult(makePar()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // assertIsCanceledSingleTransactionPlanResult
  // ---------------------------------------------------------------------------
  group('assertIsCanceledSingleTransactionPlanResult', () {
    test('does nothing for a canceled result', () {
      expect(
        () => assertIsCanceledSingleTransactionPlanResult(makeCanceled()),
        returnsNormally,
      );
    });

    test('throws for a successful single result with status in actualKind', () {
      expect(
        () => assertIsCanceledSingleTransactionPlanResult(makeSuccess()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a failed single result with status in actualKind', () {
      expect(
        () => assertIsCanceledSingleTransactionPlanResult(makeFailed()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a sequential result using kind as actualKind', () {
      expect(
        () => assertIsCanceledSingleTransactionPlanResult(makeSeq()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a parallel result using kind as actualKind', () {
      expect(
        () => assertIsCanceledSingleTransactionPlanResult(makePar()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // assertIsSequentialTransactionPlanResult
  // ---------------------------------------------------------------------------
  group('assertIsSequentialTransactionPlanResult', () {
    test('does nothing for a sequential result', () {
      expect(
        () => assertIsSequentialTransactionPlanResult(makeSeq()),
        returnsNormally,
      );
    });

    test('does nothing for a non-divisible sequential result', () {
      expect(
        () => assertIsSequentialTransactionPlanResult(makeNonDivSeq()),
        returnsNormally,
      );
    });

    test('throws for a parallel result', () {
      expect(
        () => assertIsSequentialTransactionPlanResult(makePar()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a single result', () {
      expect(
        () => assertIsSequentialTransactionPlanResult(makeSuccess()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // assertIsNonDivisibleSequentialTransactionPlanResult
  // ---------------------------------------------------------------------------
  group('assertIsNonDivisibleSequentialTransactionPlanResult', () {
    test('does nothing for a non-divisible sequential result', () {
      expect(
        () =>
            assertIsNonDivisibleSequentialTransactionPlanResult(makeNonDivSeq()),
        returnsNormally,
      );
    });

    test('throws for a divisible sequential result with actualKind qualified', () {
      expect(
        () => assertIsNonDivisibleSequentialTransactionPlanResult(makeSeq()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a parallel result using kind as actualKind', () {
      expect(
        () => assertIsNonDivisibleSequentialTransactionPlanResult(makePar()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a single result using kind as actualKind', () {
      expect(
        () =>
            assertIsNonDivisibleSequentialTransactionPlanResult(makeSuccess()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // assertIsParallelTransactionPlanResult
  // ---------------------------------------------------------------------------
  group('assertIsParallelTransactionPlanResult', () {
    test('does nothing for a parallel result', () {
      expect(
        () => assertIsParallelTransactionPlanResult(makePar()),
        returnsNormally,
      );
    });

    test('throws for a sequential result', () {
      expect(
        () => assertIsParallelTransactionPlanResult(makeSeq()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });

    test('throws for a single result', () {
      expect(
        () => assertIsParallelTransactionPlanResult(makeSuccess()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
          ),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // TransactionPlanResultStatus values
  // ---------------------------------------------------------------------------
  group('TransactionPlanResultStatus enum values', () {
    test('successful status name is "successful"', () {
      expect(TransactionPlanResultStatus.successful.name, 'successful');
    });

    test('failed status name is "failed"', () {
      expect(TransactionPlanResultStatus.failed.name, 'failed');
    });

    test('canceled status name is "canceled"', () {
      expect(TransactionPlanResultStatus.canceled.name, 'canceled');
    });

    test('all status values are distinct', () {
      const values = TransactionPlanResultStatus.values;
      expect(values.length, 3);
      expect(
        values.toSet().length,
        3,
        reason: 'all enum values should be unique',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // successfulSingleTransactionPlanResultFromTransaction: extra context fields
  // ---------------------------------------------------------------------------
  group('successfulSingleTransactionPlanResultFromTransaction extra context', () {
    test('merges extra context alongside signature and transaction', () {
      final msg = createMessage();
      final tx = createTransaction();
      final result = successfulSingleTransactionPlanResultFromTransaction(
        msg,
        tx,
        {'customKey': 'customValue'},
      );

      expect(result.context['customKey'], 'customValue');
      expect(result.context.containsKey('signature'), isTrue);
      expect(result.context.containsKey('transaction'), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // getFirstFailedSingleTransactionPlanResult – deeply nested
  // ---------------------------------------------------------------------------
  group('getFirstFailedSingleTransactionPlanResult deep nesting', () {
    test('finds a failed result inside a parallel inside a sequential', () {
      final msg = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final failedResult = makeFailed();

      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(msg, {'signature': sig}),
        parallelTransactionPlanResult([
          successfulSingleTransactionPlanResult(msg, {'signature': sig}),
          failedResult,
        ]),
      ]);

      final found = getFirstFailedSingleTransactionPlanResult(result);
      expect(found, same(failedResult));
    });
  });

  // ---------------------------------------------------------------------------
  // everyTransactionPlanResult – parallel result tree
  // ---------------------------------------------------------------------------
  group('everyTransactionPlanResult with parallel tree', () {
    test('returns true when parallel result tree all pass', () {
      final msg = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = parallelTransactionPlanResult([
        successfulSingleTransactionPlanResult(msg, {'signature': sig}),
        successfulSingleTransactionPlanResult(msg, {'signature': sig}),
      ]);

      expect(
        everyTransactionPlanResult(
          result,
          (r) =>
              r is! SingleTransactionPlanResult ||
              r is SuccessfulSingleTransactionPlanResult,
        ),
        isTrue,
      );
    });

    test('returns false when parallel result tree has a failure', () {
      final msg = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = parallelTransactionPlanResult([
        successfulSingleTransactionPlanResult(msg, {'signature': sig}),
        failedSingleTransactionPlanResult(msg, Exception('boom')),
      ]);

      expect(
        everyTransactionPlanResult(
          result,
          (r) =>
              r is! SingleTransactionPlanResult ||
              r is SuccessfulSingleTransactionPlanResult,
        ),
        isFalse,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // transformTransactionPlanResult – parallel result tree
  // ---------------------------------------------------------------------------
  group('transformTransactionPlanResult with parallel result tree', () {
    test('transforms all children of a parallel result', () {
      final msg = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      var callCount = 0;

      final result = parallelTransactionPlanResult([
        successfulSingleTransactionPlanResult(msg, {'signature': sig}),
        successfulSingleTransactionPlanResult(msg, {'signature': sig}),
      ]);

      transformTransactionPlanResult(result, (r) {
        callCount++;
        return r;
      });

      // Two single results + one parallel container = 3 calls.
      expect(callCount, 3);
    });
  });
}
