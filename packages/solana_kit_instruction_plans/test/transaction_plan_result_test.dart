import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('SuccessfulSingleTransactionPlanResult', () {
    test('creates a successful result with signature', () {
      final message = createMessage();
      final sig = Signature('test-signature'.padRight(64, '0'));
      final result = successfulSingleTransactionPlanResult(message, {
        'signature': sig,
      });

      expect(result, isA<SuccessfulSingleTransactionPlanResult>());
      expect(result.status, TransactionPlanResultStatus.successful);
      expect(result.kind, 'single');
      expect(result.plannedMessage, same(message));
      expect(result.signature, sig);
    });

    test('creates a successful result from a transaction', () {
      final message = createMessage();
      final transaction = createTransaction();
      final result = successfulSingleTransactionPlanResultFromTransaction(
        message,
        transaction,
      );

      expect(result, isA<SuccessfulSingleTransactionPlanResult>());
      expect(result.status, TransactionPlanResultStatus.successful);
      expect(result.context.containsKey('signature'), isTrue);
      expect(result.context.containsKey('transaction'), isTrue);
      expect(result.context['transaction'], same(transaction));
    });

    test('context is unmodifiable', () {
      final message = createMessage();
      final sig = Signature('test-signature'.padRight(64, '0'));
      final result = successfulSingleTransactionPlanResult(message, {
        'signature': sig,
      });

      expect(
        () => (result.context as Map)['new_key'] = 'value',
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('FailedSingleTransactionPlanResult', () {
    test('creates a failed result with error', () {
      final message = createMessage();
      final error = Exception('test error');
      final result = failedSingleTransactionPlanResult(message, error);

      expect(result, isA<FailedSingleTransactionPlanResult>());
      expect(result.status, TransactionPlanResultStatus.failed);
      expect(result.kind, 'single');
      expect(result.plannedMessage, same(message));
      expect(result.error, same(error));
    });

    test('creates a failed result with context', () {
      final message = createMessage();
      final error = Exception('test error');
      final result = failedSingleTransactionPlanResult(message, error, {
        'key': 'value',
      });

      expect(result.context['key'], 'value');
    });

    test('context defaults to empty when not provided', () {
      final message = createMessage();
      final result = failedSingleTransactionPlanResult(
        message,
        Exception('test'),
      );

      expect(result.context, isEmpty);
    });
  });

  group('CanceledSingleTransactionPlanResult', () {
    test('creates a canceled result', () {
      final message = createMessage();
      final result = canceledSingleTransactionPlanResult(message);

      expect(result, isA<CanceledSingleTransactionPlanResult>());
      expect(result.status, TransactionPlanResultStatus.canceled);
      expect(result.kind, 'single');
      expect(result.plannedMessage, same(message));
    });

    test('creates a canceled result with context', () {
      final message = createMessage();
      final result = canceledSingleTransactionPlanResult(message, {
        'key': 'value',
      });

      expect(result.context['key'], 'value');
    });
  });

  group('SequentialTransactionPlanResult', () {
    test('creates a sequential result', () {
      final message = createMessage();
      final sig = Signature('test-signature'.padRight(64, '0'));
      final childResult = successfulSingleTransactionPlanResult(message, {
        'signature': sig,
      });
      final result = sequentialTransactionPlanResult([childResult]);

      expect(result, isA<SequentialTransactionPlanResult>());
      expect(result.kind, 'sequential');
      expect(result.divisible, isTrue);
      expect(result.plans, hasLength(1));
    });

    test('creates a non-divisible sequential result', () {
      final result = nonDivisibleSequentialTransactionPlanResult([]);

      expect(result, isA<SequentialTransactionPlanResult>());
      expect(result.divisible, isFalse);
    });
  });

  group('ParallelTransactionPlanResult', () {
    test('creates a parallel result', () {
      final message = createMessage();
      final sig = Signature('test-signature'.padRight(64, '0'));
      final childResult = successfulSingleTransactionPlanResult(message, {
        'signature': sig,
      });
      final result = parallelTransactionPlanResult([childResult]);

      expect(result, isA<ParallelTransactionPlanResult>());
      expect(result.kind, 'parallel');
      expect(result.plans, hasLength(1));
    });
  });

  group('isTransactionPlanResult', () {
    test('returns true for all result types', () {
      final message = createMessage();
      final sig = Signature('test-signature'.padRight(64, '0'));

      expect(
        isTransactionPlanResult(
          successfulSingleTransactionPlanResult(message, {'signature': sig}),
        ),
        isTrue,
      );
      expect(
        isTransactionPlanResult(
          failedSingleTransactionPlanResult(message, Exception('test')),
        ),
        isTrue,
      );
      expect(
        isTransactionPlanResult(canceledSingleTransactionPlanResult(message)),
        isTrue,
      );
      expect(
        isTransactionPlanResult(sequentialTransactionPlanResult([])),
        isTrue,
      );
      expect(
        isTransactionPlanResult(parallelTransactionPlanResult([])),
        isTrue,
      );
    });

    test('returns false for non-result values', () {
      expect(isTransactionPlanResult(null), isFalse);
      expect(isTransactionPlanResult('string'), isFalse);
      expect(isTransactionPlanResult(123), isFalse);
    });
  });

  group('isSingleTransactionPlanResult', () {
    test('returns true for single results', () {
      final message = createMessage();
      final sig = Signature('test-signature'.padRight(64, '0'));

      expect(
        isSingleTransactionPlanResult(
          successfulSingleTransactionPlanResult(message, {'signature': sig}),
        ),
        isTrue,
      );
      expect(
        isSingleTransactionPlanResult(
          failedSingleTransactionPlanResult(message, Exception('test')),
        ),
        isTrue,
      );
      expect(
        isSingleTransactionPlanResult(
          canceledSingleTransactionPlanResult(message),
        ),
        isTrue,
      );
    });

    test('returns false for non-single results', () {
      expect(
        isSingleTransactionPlanResult(sequentialTransactionPlanResult([])),
        isFalse,
      );
      expect(
        isSingleTransactionPlanResult(parallelTransactionPlanResult([])),
        isFalse,
      );
    });
  });

  group('assertIsSingleTransactionPlanResult', () {
    test('does nothing for single results', () {
      final message = createMessage();
      final sig = Signature('test-signature'.padRight(64, '0'));
      expect(
        () => assertIsSingleTransactionPlanResult(
          successfulSingleTransactionPlanResult(message, {'signature': sig}),
        ),
        returnsNormally,
      );
    });

    test('throws SolanaError for non-single results', () {
      expect(
        () => assertIsSingleTransactionPlanResult(
          sequentialTransactionPlanResult([]),
        ),
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

  group('isSuccessfulSingleTransactionPlanResult', () {
    test('returns true for successful results', () {
      final message = createMessage();
      final sig = Signature('test-signature'.padRight(64, '0'));
      expect(
        isSuccessfulSingleTransactionPlanResult(
          successfulSingleTransactionPlanResult(message, {'signature': sig}),
        ),
        isTrue,
      );
    });

    test('returns false for non-successful results', () {
      final message = createMessage();
      expect(
        isSuccessfulSingleTransactionPlanResult(
          failedSingleTransactionPlanResult(message, Exception('test')),
        ),
        isFalse,
      );
      expect(
        isSuccessfulSingleTransactionPlanResult(
          canceledSingleTransactionPlanResult(message),
        ),
        isFalse,
      );
    });
  });

  group('isFailedSingleTransactionPlanResult', () {
    test('returns true for failed results', () {
      final message = createMessage();
      expect(
        isFailedSingleTransactionPlanResult(
          failedSingleTransactionPlanResult(message, Exception('test')),
        ),
        isTrue,
      );
    });

    test('returns false for non-failed results', () {
      final message = createMessage();
      final sig = Signature('test-signature'.padRight(64, '0'));
      expect(
        isFailedSingleTransactionPlanResult(
          successfulSingleTransactionPlanResult(message, {'signature': sig}),
        ),
        isFalse,
      );
    });
  });

  group('isCanceledSingleTransactionPlanResult', () {
    test('returns true for canceled results', () {
      final message = createMessage();
      expect(
        isCanceledSingleTransactionPlanResult(
          canceledSingleTransactionPlanResult(message),
        ),
        isTrue,
      );
    });

    test('returns false for non-canceled results', () {
      final message = createMessage();
      final sig = Signature('test-signature'.padRight(64, '0'));
      expect(
        isCanceledSingleTransactionPlanResult(
          successfulSingleTransactionPlanResult(message, {'signature': sig}),
        ),
        isFalse,
      );
    });
  });

  group('isSequentialTransactionPlanResult', () {
    test('returns true for sequential results', () {
      expect(
        isSequentialTransactionPlanResult(sequentialTransactionPlanResult([])),
        isTrue,
      );
    });

    test('returns false for non-sequential results', () {
      expect(
        isSequentialTransactionPlanResult(parallelTransactionPlanResult([])),
        isFalse,
      );
    });
  });

  group('isNonDivisibleSequentialTransactionPlanResult', () {
    test('returns true for non-divisible sequential results', () {
      expect(
        isNonDivisibleSequentialTransactionPlanResult(
          nonDivisibleSequentialTransactionPlanResult([]),
        ),
        isTrue,
      );
    });

    test('returns false for divisible sequential results', () {
      expect(
        isNonDivisibleSequentialTransactionPlanResult(
          sequentialTransactionPlanResult([]),
        ),
        isFalse,
      );
    });
  });

  group('isParallelTransactionPlanResult', () {
    test('returns true for parallel results', () {
      expect(
        isParallelTransactionPlanResult(parallelTransactionPlanResult([])),
        isTrue,
      );
    });

    test('returns false for non-parallel results', () {
      expect(
        isParallelTransactionPlanResult(sequentialTransactionPlanResult([])),
        isFalse,
      );
    });
  });

  group('getFirstFailedSingleTransactionPlanResult', () {
    test('returns the first failed result', () {
      final message = createMessage();
      final error = Exception('test error');
      final failedResult = failedSingleTransactionPlanResult(message, error);
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {
          'signature': Signature('sig'.padRight(64, '0')),
        }),
        failedResult,
      ]);

      final found = getFirstFailedSingleTransactionPlanResult(result);
      expect(found, same(failedResult));
    });

    test('throws SolanaError when no failed result exists', () {
      final message = createMessage();
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {
          'signature': Signature('sig'.padRight(64, '0')),
        }),
      ]);

      expect(
        () => getFirstFailedSingleTransactionPlanResult(result),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .instructionPlansFailedSingleTransactionPlanResultNotFound,
          ),
        ),
      );
    });
  });

  group('isSuccessfulTransactionPlanResult', () {
    test('returns true when all results are successful', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
      ]);

      expect(isSuccessfulTransactionPlanResult(result), isTrue);
    });

    test('returns false when any result is failed', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
        failedSingleTransactionPlanResult(message, Exception('test')),
      ]);

      expect(isSuccessfulTransactionPlanResult(result), isFalse);
    });

    test('returns false when any result is canceled', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
        canceledSingleTransactionPlanResult(message),
      ]);

      expect(isSuccessfulTransactionPlanResult(result), isFalse);
    });
  });

  group('assertIsSuccessfulTransactionPlanResult', () {
    test('does nothing when all results are successful', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
      ]);

      expect(
        () => assertIsSuccessfulTransactionPlanResult(result),
        returnsNormally,
      );
    });

    test('throws SolanaError when any result is not successful', () {
      final message = createMessage();
      final result = sequentialTransactionPlanResult([
        failedSingleTransactionPlanResult(message, Exception('test')),
      ]);

      expect(
        () => assertIsSuccessfulTransactionPlanResult(result),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .instructionPlansExpectedSuccessfulTransactionPlanResult,
          ),
        ),
      );
    });
  });

  group('flattenTransactionPlanResult', () {
    test('returns a single result in a list', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = successfulSingleTransactionPlanResult(message, {
        'signature': sig,
      });

      final flattened = flattenTransactionPlanResult(result);
      expect(flattened, hasLength(1));
      expect(flattened[0], same(result));
    });

    test('flattens nested results', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
        parallelTransactionPlanResult([
          failedSingleTransactionPlanResult(message, Exception('test')),
          canceledSingleTransactionPlanResult(message),
        ]),
      ]);

      final flattened = flattenTransactionPlanResult(result);
      expect(flattened, hasLength(3));
      expect(flattened[0], isA<SuccessfulSingleTransactionPlanResult>());
      expect(flattened[1], isA<FailedSingleTransactionPlanResult>());
      expect(flattened[2], isA<CanceledSingleTransactionPlanResult>());
    });
  });

  group('summarizeTransactionPlanResult', () {
    test('summarizes a fully successful result', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
      ]);

      final summary = summarizeTransactionPlanResult(result);
      expect(summary.successful, isTrue);
      expect(summary.successfulTransactions, hasLength(2));
      expect(summary.failedTransactions, isEmpty);
      expect(summary.canceledTransactions, isEmpty);
    });

    test('summarizes a result with failures', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
        failedSingleTransactionPlanResult(message, Exception('test')),
        canceledSingleTransactionPlanResult(message),
      ]);

      final summary = summarizeTransactionPlanResult(result);
      expect(summary.successful, isFalse);
      expect(summary.successfulTransactions, hasLength(1));
      expect(summary.failedTransactions, hasLength(1));
      expect(summary.canceledTransactions, hasLength(1));
    });

    test('handles nested parallel and sequential results', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = parallelTransactionPlanResult([
        sequentialTransactionPlanResult([
          successfulSingleTransactionPlanResult(message, {'signature': sig}),
          successfulSingleTransactionPlanResult(message, {'signature': sig}),
        ]),
        failedSingleTransactionPlanResult(message, Exception('test')),
      ]);

      final summary = summarizeTransactionPlanResult(result);
      expect(summary.successful, isFalse);
      expect(summary.successfulTransactions, hasLength(2));
      expect(summary.failedTransactions, hasLength(1));
    });
  });

  group('findTransactionPlanResult', () {
    test('returns the result itself when it matches the predicate', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = successfulSingleTransactionPlanResult(message, {
        'signature': sig,
      });
      final found = findTransactionPlanResult(
        result,
        (r) => r is SuccessfulSingleTransactionPlanResult,
      );
      expect(found, same(result));
    });

    test('returns null when no result matches', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = successfulSingleTransactionPlanResult(message, {
        'signature': sig,
      });
      final found = findTransactionPlanResult(
        result,
        (r) => r is FailedSingleTransactionPlanResult,
      );
      expect(found, isNull);
    });

    test('finds a nested result', () {
      final message = createMessage();
      final failedResult = failedSingleTransactionPlanResult(
        message,
        Exception('test'),
      );
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {
          'signature': Signature('sig'.padRight(64, '0')),
        }),
        failedResult,
      ]);
      final found = findTransactionPlanResult(
        result,
        (r) => r is FailedSingleTransactionPlanResult,
      );
      expect(found, same(failedResult));
    });
  });

  group('everyTransactionPlanResult', () {
    test('returns true when all results match', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
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

    test('returns false when any result does not match', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
        failedSingleTransactionPlanResult(message, Exception('test')),
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

  group('transformTransactionPlanResult', () {
    test('transforms single results', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = successfulSingleTransactionPlanResult(message, {
        'signature': sig,
      });

      final transformed = transformTransactionPlanResult(result, (r) {
        if (r is SuccessfulSingleTransactionPlanResult) {
          return canceledSingleTransactionPlanResult(r.plannedMessage);
        }
        return r;
      });

      expect(transformed, isA<CanceledSingleTransactionPlanResult>());
    });

    test('transforms nested results bottom-up', () {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message, {'signature': sig}),
        failedSingleTransactionPlanResult(message, Exception('test')),
      ]);

      final kinds = <String>[];
      transformTransactionPlanResult(result, (r) {
        kinds.add(r.kind);
        return r;
      });

      // Bottom-up: first single, second single, then sequential
      expect(kinds, hasLength(3));
    });
  });
}
