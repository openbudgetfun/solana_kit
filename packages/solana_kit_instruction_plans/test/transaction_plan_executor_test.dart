import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('createTransactionPlanExecutor', () {
    test('executes a single transaction plan successfully', () async {
      final message = createMessage();
      final plan = singleTransactionPlan(message);
      final sig = Signature('test-signature'.padRight(64, '0'));

      final executor = createTransactionPlanExecutor(
        TransactionPlanExecutorConfig(
          executeTransactionMessage: (context, msg) async => sig.toString(),
        ),
      );

      final result = await executor(plan);

      expect(result, isA<SuccessfulSingleTransactionPlanResult>());
      final successResult = result as SuccessfulSingleTransactionPlanResult;
      expect(successResult.plannedMessage, same(message));
    });

    test(
      'executes a single transaction plan returning a Transaction',
      () async {
        final message = createMessage();
        final plan = singleTransactionPlan(message);
        final transaction = createTransaction();

        final executor = createTransactionPlanExecutor(
          TransactionPlanExecutorConfig(
            executeTransactionMessage: (context, msg) async => transaction,
          ),
        );

        final result = await executor(plan);

        expect(result, isA<SuccessfulSingleTransactionPlanResult>());
        final successResult = result as SuccessfulSingleTransactionPlanResult;
        expect(successResult.context.containsKey('transaction'), isTrue);
      },
    );

    test(
      'executes a single transaction plan returning a result context',
      () async {
        final message = createMessage();
        final plan = singleTransactionPlan(message);
        final sig = Signature('test-signature'.padRight(64, '0'));

        final executor = createTransactionPlanExecutor(
          TransactionPlanExecutorConfig(
            executeTransactionMessage: (context, msg) async => {
              'signature': sig,
              'custom': 'value',
            },
          ),
        );

        final result = await executor(plan);

        expect(result, isA<SuccessfulSingleTransactionPlanResult>());
        final successResult = result as SuccessfulSingleTransactionPlanResult;
        expect(successResult.signature, sig);
        expect(successResult.context['custom'], 'value');
      },
    );

    test('executes a sequential transaction plan', () async {
      final messageA = createMessage();
      final messageB = createMessage();
      final plan = sequentialTransactionPlan([messageA, messageB]);
      final sig = Signature('test-signature'.padRight(64, '0'));

      final executor = createTransactionPlanExecutor(
        TransactionPlanExecutorConfig(
          executeTransactionMessage: (context, msg) async => sig.toString(),
        ),
      );

      final result = await executor(plan);

      expect(result, isA<SequentialTransactionPlanResult>());
      final seqResult = result as SequentialTransactionPlanResult;
      expect(seqResult.plans, hasLength(2));
      expect(seqResult.plans[0], isA<SuccessfulSingleTransactionPlanResult>());
      expect(seqResult.plans[1], isA<SuccessfulSingleTransactionPlanResult>());
    });

    test('executes a parallel transaction plan', () async {
      final messageA = createMessage();
      final messageB = createMessage();
      final plan = parallelTransactionPlan([messageA, messageB]);
      final sig = Signature('test-signature'.padRight(64, '0'));

      final executor = createTransactionPlanExecutor(
        TransactionPlanExecutorConfig(
          executeTransactionMessage: (context, msg) async => sig.toString(),
        ),
      );

      final result = await executor(plan);

      expect(result, isA<ParallelTransactionPlanResult>());
      final parResult = result as ParallelTransactionPlanResult;
      expect(parResult.plans, hasLength(2));
    });

    test('cancels remaining transactions on failure', () async {
      final messageA = createMessage();
      final messageB = createMessage();
      final plan = sequentialTransactionPlan([messageA, messageB]);
      var callCount = 0;

      final executor = createTransactionPlanExecutor(
        TransactionPlanExecutorConfig(
          executeTransactionMessage: (context, msg) async {
            callCount++;
            if (callCount == 1) {
              throw Exception('first transaction failed');
            }
            return Signature('sig'.padRight(64, '0')).toString();
          },
        ),
      );

      expect(
        () => executor(plan),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan,
          ),
        ),
      );
    });

    test('reports the abort reason for a failed parallel plan', () async {
      final messageA = createMessage();
      final messageB = createMessage();
      final plan = parallelTransactionPlan([messageA, messageB]);

      final executor = createTransactionPlanExecutor(
        TransactionPlanExecutorConfig(
          executeTransactionMessage: (context, msg) async {
            throw Exception('parallel transaction failed');
          },
        ),
      );

      expect(
        () => executor(plan),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan,
          ),
        ),
      );
    });

    test('throws for non-divisible sequential transaction plans', () async {
      final messageA = createMessage();
      final messageB = createMessage();
      final plan = nonDivisibleSequentialTransactionPlan([messageA, messageB]);

      final executor = createTransactionPlanExecutor(
        TransactionPlanExecutorConfig(
          executeTransactionMessage: (context, msg) async {
            return Signature('sig'.padRight(64, '0')).toString();
          },
        ),
      );

      expect(
        () => executor(plan),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode
                .instructionPlansNonDivisibleTransactionPlansNotSupported,
          ),
        ),
      );
    });

    test('provides context to executeTransactionMessage', () async {
      final message = createMessage();
      final plan = singleTransactionPlan(message);
      Map<String, Object?>? capturedContext;

      final executor = createTransactionPlanExecutor(
        TransactionPlanExecutorConfig(
          executeTransactionMessage: (context, msg) async {
            capturedContext = context;
            context['myKey'] = 'myValue';
            return Signature('sig'.padRight(64, '0')).toString();
          },
        ),
      );

      final result = await executor(plan);

      expect(capturedContext, isNotNull);
      expect(result, isA<SuccessfulSingleTransactionPlanResult>());
      final successResult = result as SuccessfulSingleTransactionPlanResult;
      expect(successResult.context['myKey'], 'myValue');
    });

    test('extracts signature from transaction in context on failure', () async {
      final message = createMessage();
      final plan = singleTransactionPlan(message);
      final transaction = createTransaction();

      final executor = createTransactionPlanExecutor(
        TransactionPlanExecutorConfig(
          executeTransactionMessage: (context, msg) async {
            context['transaction'] = transaction;
            throw Exception('failed after signing');
          },
        ),
      );

      try {
        await executor(plan);
        fail('Expected SolanaError');
      } on SolanaError catch (e) {
        expect(
          e.code,
          SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan,
        );
      }
    });

    test(
      'returns canceled result when execution is already canceled',
      () async {
        final messageA = createMessage();
        final messageB = createMessage();
        var callCount = 0;

        final executor = createTransactionPlanExecutor(
          TransactionPlanExecutorConfig(
            executeTransactionMessage: (context, msg) async {
              callCount++;
              if (callCount == 1) {
                throw Exception('first transaction failed');
              }
              return Signature('sig'.padRight(64, '0')).toString();
            },
          ),
        );

        // Execute a sequential plan where the first fails.
        // The second should be canceled.
        final plan = sequentialTransactionPlan([messageA, messageB]);

        try {
          await executor(plan);
          fail('Expected SolanaError');
        } on SolanaError catch (_) {
          // Expected
        }

        // Only 1 call should have been made (second was canceled).
        expect(callCount, 1);
      },
    );
  });

  group('createTransactionPlanExecutorWithConcurrentLeaves', () {
    test('preserves plan nesting, order, and divisibility', () async {
      final messageA = createMessage();
      final messageB = createMessage();
      final messageC = createMessage();
      final messageD = createMessage();
      final plan = parallelTransactionPlan([
        nonDivisibleSequentialTransactionPlan([messageA, messageB]),
        sequentialTransactionPlan([messageC, messageD]),
      ]);
      final executor = createTransactionPlanExecutorWithConcurrentLeaves(
        TransactionPlanExecutorConfig(
          executeTransactionMessage: (context, msg) async {
            return {'signature': Signature('sig'.padRight(64, '0'))};
          },
        ),
      );

      final result = await executor(plan);

      expect(result, isA<ParallelTransactionPlanResult>());
      final parallelResult = result as ParallelTransactionPlanResult;
      expect(parallelResult.plans, hasLength(2));
      expect(
        parallelResult.plans[0],
        isA<SequentialTransactionPlanResult>(),
      );
      expect(
        (parallelResult.plans[0] as SequentialTransactionPlanResult).divisible,
        isFalse,
      );
      expect(parallelResult.plans[1], isA<SequentialTransactionPlanResult>());
      expect(
        (parallelResult.plans[0] as SequentialTransactionPlanResult).plans,
        hasLength(2),
      );
      expect(
        (parallelResult.plans[0] as SequentialTransactionPlanResult).plans[0],
        isA<SuccessfulSingleTransactionPlanResult>(),
      );
    });

    test('starts leaves in sequential plans concurrently', () async {
      final messageA = createMessage();
      final messageB = createMessage();
      final plan = sequentialTransactionPlan([messageA, messageB]);
      final completers = <Completer<Object>>[
        Completer<Object>(),
        Completer<Object>(),
      ];
      var calls = 0;

      final executor = createTransactionPlanExecutorWithConcurrentLeaves(
        TransactionPlanExecutorConfig(
          executeTransactionMessage: (context, msg) =>
              completers[calls++].future,
        ),
      );

      // The executor future is intentionally left unawaited here; the
      // assertion is that both leaves start before either completes.
      unawaited(executor(plan));
      await Future<void>.delayed(Duration.zero);
      expect(calls, 2);

      completers[0].complete('test-signature'.padRight(64, '0'));
      completers[1].complete('test-signature'.padRight(64, '0'));
    });

    test(
      'aggregates thrown leaf errors without canceling other leaves',
      () async {
        final messageA = createMessage();
        final messageB = createMessage();
        final messageC = createMessage();
        final errorA = StateError('A failed');
        final errorC = StateError('C failed');
        final plan = nonDivisibleSequentialTransactionPlan([
          messageA,
          messageB,
          messageC,
        ]);
        final executor = createTransactionPlanExecutorWithConcurrentLeaves(
          TransactionPlanExecutorConfig(
            executeTransactionMessage: (context, msg) async {
              if (identical(msg, messageA)) throw errorA;
              if (identical(msg, messageC)) throw errorC;
              return {
                'signature': Signature('sig-b'.padRight(64, '0')),
              };
            },
          ),
        );

        Object? captured;
        try {
          await executor(plan);
        } on Object catch (e) {
          captured = e;
        }
        final error = captured!;

        expect(
          isSolanaError(
            error,
            SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan,
          ),
          isTrue,
        );
        final solanaError = error as SolanaError;
        expect(solanaError.context['cause'], errorA);
        final planResult = solanaError.context['transactionPlanResult'];
        final result = planResult! as SequentialTransactionPlanResult;
        expect(result.divisible, isFalse);
        expect(result.plans, hasLength(3));
        expect(result.plans[0], isA<FailedSingleTransactionPlanResult>());
        expect(result.plans[1], isA<SuccessfulSingleTransactionPlanResult>());
        expect(result.plans[2], isA<FailedSingleTransactionPlanResult>());
      },
    );

    test('supports non-divisible sequential plans', () async {
      final message = createMessage();
      final plan = nonDivisibleSequentialTransactionPlan([message]);
      final executor = createTransactionPlanExecutorWithConcurrentLeaves(
        TransactionPlanExecutorConfig(
          executeTransactionMessage: (context, msg) async =>
              'test-signature'.padRight(64, '0'),
        ),
      );

      final result = await executor(plan);

      expect(result, isA<SequentialTransactionPlanResult>());
      expect(
        (result as SequentialTransactionPlanResult).divisible,
        isFalse,
      );
    });

    test('preserves partial context on failed leaves', () async {
      final message = createMessage();
      final plan = singleTransactionPlan(message);
      final executor = createTransactionPlanExecutorWithConcurrentLeaves(
        TransactionPlanExecutorConfig(
          executeTransactionMessage: (context, msg) async {
            context['custom'] = 'recorded';
            throw StateError('boom');
          },
        ),
      );

      Object? captured;
      try {
        await executor(plan);
      } on Object catch (e) {
        captured = e;
      }
      final error = captured!;

      expect(error, isA<SolanaError>());
      final result =
          (error as SolanaError).context['transactionPlanResult']!
              as FailedSingleTransactionPlanResult;
      expect(result.context['custom'], 'recorded');
    });

    test(
      'executes a single transaction plan returning a Transaction',
      () async {
        final message = createMessage();
        final plan = singleTransactionPlan(message);
        final transaction = createTransaction();

        final executor = createTransactionPlanExecutorWithConcurrentLeaves(
          TransactionPlanExecutorConfig(
            executeTransactionMessage: (context, msg) async => transaction,
          ),
        );

        final result = await executor(plan);

        expect(result, isA<SuccessfulSingleTransactionPlanResult>());
        final successResult = result as SuccessfulSingleTransactionPlanResult;
        expect(successResult.context.containsKey('transaction'), isTrue);
        expect(successResult.context['signature'], isA<Signature>());
      },
    );
  });

  group('TransactionPlanExecutorConfig', () {
    test('stores the executeTransactionMessage callback', () {
      Future<Object> callback(
        Map<String, Object?> context,
        dynamic msg,
      ) async => 'result';

      final config = TransactionPlanExecutorConfig(
        executeTransactionMessage: callback,
      );
      expect(config.executeTransactionMessage, same(callback));
    });
  });

  group('passthroughFailedTransactionPlanExecution', () {
    test('returns successful result unchanged', () async {
      final message = createMessage();
      final sig = Signature('sig'.padRight(64, '0'));
      final expectedResult = successfulSingleTransactionPlanResult(message, {
        'signature': sig,
      });

      final result = await passthroughFailedTransactionPlanExecution(
        Future.value(expectedResult),
      );

      expect(result, same(expectedResult));
    });

    test('rethrows non-SolanaError exceptions', () {
      expect(
        () => passthroughFailedTransactionPlanExecution(
          Future<TransactionPlanResult>.error(Exception('other error')),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('rethrows SolanaError without transactionPlanResult in context', () {
      final error = SolanaError(
        SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan,
        {'cause': 'test'},
      );

      expect(
        () => passthroughFailedTransactionPlanExecution(
          Future<TransactionPlanResult>.error(error),
        ),
        throwsA(isA<SolanaError>()),
      );
    });
  });
}
