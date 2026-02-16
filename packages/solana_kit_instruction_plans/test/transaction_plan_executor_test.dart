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
