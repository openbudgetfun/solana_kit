import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('execution failure preserves prior transaction results', () {
    for (final hasFeePayer in [false, true]) {
      test('retains successful payments when an unsigned transaction fails '
          '(fee-payer slot present: $hasFeePayer)', () async {
        final unsigned = compileTransaction(createMessage());
        final transaction = Transaction(
          messageBytes: unsigned.messageBytes,
          signatures: hasFeePayer ? unsigned.signatures : {},
        );
        final signature = getSignatureFromTransaction(createTransaction());
        final failure = StateError('User declined to sign the second payment');
        var attempts = 0;
        final executor = createTransactionPlanExecutor(
          TransactionPlanExecutorConfig(
            executeTransactionMessage: (context, message) async {
              attempts++;
              if (attempts == 1) return {'signature': signature};
              context['transaction'] = transaction;
              throw failure;
            },
          ),
        );

        final result = await passthroughFailedTransactionPlanExecution(
          executor(
            sequentialTransactionPlan([
              createMessage(),
              createMessage(),
              createMessage(),
            ]),
          ),
        );
        final results = flattenTransactionPlanResult(result);

        expect(attempts, 2);
        expect(results.map((result) => result.status), [
          TransactionPlanResultStatus.successful,
          TransactionPlanResultStatus.failed,
          TransactionPlanResultStatus.canceled,
        ]);
        expect(results.first.context['signature'], signature);
        final failed = results[1] as FailedSingleTransactionPlanResult;
        expect(failed.error, same(failure));
        expect(failed.context['transaction'], same(transaction));
        expect(failed.context.containsKey('signature'), isFalse);
      });
    }

    test(
      'preserves the sending failure stage for unsigned transactions',
      () async {
        final message = createMessage();
        final failure = StateError('Cannot submit an unsigned transaction');
        final boundary = createTransactionExecutionBoundary(
          TransactionExecutionBoundaryConfig(
            planTransactions: (_, {maxInstructionsPerTransaction}) async =>
                singleTransactionPlan(message),
            signTransactionMessage: (_) async => compileTransaction(message),
            sendSignedTransaction: (_) async => throw failure,
          ),
        );

        final outcome =
            await boundary(
                  singleInstructionPlan(createInstruction()),
                )
                as FailedTransactionExecution;

        expect(outcome.stage, TransactionExecutionFailureStage.sending);
        expect(outcome.error, same(failure));
        expect(
          outcome.transactionPlanResult,
          isA<FailedSingleTransactionPlanResult>(),
        );
      },
    );
  });
}
