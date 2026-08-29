import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

const preflightLogs = [
  'Program log: Instruction: Transfer',
  'Program failed: insufficient funds',
];

const Map<String, Object?> preflightContext = {
  'accounts': null,
  'fee': null,
  'loadedAccountsDataSize': null,
  'loadedAddresses': {'readonly': <String>[], 'writable': <String>[]},
  'logs': preflightLogs,
  'postBalances': null,
  'postTokenBalances': null,
  'preBalances': null,
  'preTokenBalances': null,
  'replacementBlockhash': null,
  'returnData': null,
  'unitsConsumed': null,
};

const Map<String, Object?> preflightContextWithoutLogs = {
  'accounts': null,
  'fee': null,
  'loadedAccountsDataSize': null,
  'loadedAddresses': {'readonly': <String>[], 'writable': <String>[]},
  'logs': null,
  'postBalances': null,
  'postTokenBalances': null,
  'preBalances': null,
  'preTokenBalances': null,
  'replacementBlockhash': null,
  'returnData': null,
  'unitsConsumed': null,
};

const signature =
    '5wHu1qwD7q5ifaN5nwdcDQNbHUiCfnzJ6vaR98NLugS1CiVfCZLMGmmFaKCAVfPTFE5KPMh'
    'SaZaLo2v4xXSHVJk';

TransactionMessage message(String label) =>
    const TransactionMessage(version: TransactionVersion.v0);

SolanaError createPreflightError(Object causeError, Map<String, Object?> logs) {
  return SolanaError(
    SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
    {...logs, 'cause': causeError},
  );
}

void main() {
  group('createFailedToSendTransactionError', () {
    test('unwraps a preflight error and exposes preflight data and logs', () {
      final innerError = SolanaError(
        SolanaErrorCode.transactionErrorInsufficientFundsForFee,
      );
      final preflightError = createPreflightError(innerError, preflightContext);
      final result = failedSingleTransactionPlanResult(
        message('A'),
        preflightError,
      );

      final error = createFailedToSendTransactionError(result);

      expect(error.context['cause'], same(innerError));
      expect(error.context['preflightData'], preflightContext);
      expect(error.context['logs'], preflightLogs);
    });

    test('renders an arbitrary error type through its toString', () {
      final result = failedSingleTransactionPlanResult(
        message('A'),
        const FormatException('boom'),
      );

      final error = createFailedToSendTransactionError(result);

      expect(error.context['cause'], same(result.error));
      expect(
        getErrorMessage(error.code, error.context),
        contains('FormatException: boom'),
      );
    });

    test('sets logs to null when preflight logs are null', () {
      final innerError = SolanaError(
        SolanaErrorCode.transactionErrorInsufficientFundsForFee,
      );
      final preflightError = createPreflightError(
        innerError,
        preflightContextWithoutLogs,
      );
      final result = failedSingleTransactionPlanResult(
        message('A'),
        preflightError,
      );

      final error = createFailedToSendTransactionError(result);

      expect(error.context['logs'], isNull);
    });

    test('includes the (preflight) indicator and inner message', () {
      final innerError = SolanaError(
        SolanaErrorCode.transactionErrorInsufficientFundsForFee,
      );
      final preflightError = createPreflightError(innerError, {
        ...preflightContext,
        'logs': <String>[],
      });
      final result = failedSingleTransactionPlanResult(
        message('A'),
        preflightError,
      );

      final error = createFailedToSendTransactionError(result);

      expect(
        getErrorMessage(error.code, error.context),
        'Failed to send transaction (preflight): '
        '${getErrorMessage(innerError.code, innerError.context)}',
      );
    });

    test('uses the error directly when it is not a simulation error', () {
      final plainError = StateError('Connection refused');
      final result = failedSingleTransactionPlanResult(
        message('A'),
        plainError,
      );

      final error = createFailedToSendTransactionError(result);

      expect(error.context['cause'], same(plainError));
      expect(error.context['preflightData'], isNull);
      expect(error.context['logs'], isNull);
      expect(
        getErrorMessage(error.code, error.context),
        'Failed to send transaction: Connection refused',
      );
    });

    test('quotes the signature when one sits in the result context', () {
      final result = failedSingleTransactionPlanResult(
        message('A'),
        StateError('Transaction failed'),
        {'signature': signature},
      );

      final error = createFailedToSendTransactionError(result);

      expect(
        getErrorMessage(error.code, error.context),
        'Failed to send transaction ($signature): Transaction failed',
      );
    });

    test('omits a non-string signature from the message', () {
      final result = failedSingleTransactionPlanResult(
        message('A'),
        StateError('Transaction failed'),
        {'signature': 42},
      );

      final error = createFailedToSendTransactionError(result);

      expect(
        getErrorMessage(error.code, error.context),
        'Failed to send transaction: Transaction failed',
      );
    });

    test('appends the last 8 log lines when there are more than 8', () {
      final logs = List.generate(12, (i) => 'Log line ${i + 1}');
      final innerError = SolanaError(
        SolanaErrorCode.transactionErrorInsufficientFundsForFee,
      );
      final preflightError = createPreflightError(innerError, {
        ...preflightContext,
        'logs': logs,
      });
      final result = failedSingleTransactionPlanResult(
        message('A'),
        preflightError,
      );

      final error = createFailedToSendTransactionError(result);

      expect(
        getErrorMessage(error.code, error.context),
        'Failed to send transaction (preflight): '
        '${getErrorMessage(innerError.code, innerError.context)}\n\n'
        'Logs (last 8 of 12):\n'
        '  > Log line 5\n'
        '  > Log line 6\n'
        '  > Log line 7\n'
        '  > Log line 8\n'
        '  > Log line 9\n'
        '  > Log line 10\n'
        '  > Log line 11\n'
        '  > Log line 12\n',
      );
    });

    test('reports the abort reason for a canceled result', () {
      final abortReason = StateError('User canceled');
      final result = canceledSingleTransactionPlanResult(message('A'));

      final error = createFailedToSendTransactionError(result, abortReason);

      expect(error.context['cause'], same(abortReason));
      expect(
        getErrorMessage(error.code, error.context),
        'Failed to send transaction. Canceled with abort reason: '
        'Bad state: User canceled',
      );
      expect(error.context['preflightData'], isNull);
      expect(error.context['logs'], isNull);
    });

    test('reports a plain cancel when there is no abort reason', () {
      final result = canceledSingleTransactionPlanResult(message('A'));

      final error = createFailedToSendTransactionError(result);

      expect(
        getErrorMessage(error.code, error.context),
        'Failed to send transaction: Canceled',
      );
      expect(error.context['cause'], isNull);
    });

    test('carries the transactionPlanResult in the context', () {
      final result = failedSingleTransactionPlanResult(
        message('A'),
        StateError('fail'),
      );

      final error = createFailedToSendTransactionError(result);

      expect(error.context['transactionPlanResult'], same(result));
      expect(error.code, SolanaErrorCode.failedToSendTransaction);
    });
  });

  group('createFailedToSendTransactionsError', () {
    test('lists only the failed transactions with 0-based indices', () {
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message('A'), {
          'signature': signature,
        }),
        failedSingleTransactionPlanResult(message('B'), StateError('B failed')),
        canceledSingleTransactionPlanResult(message('C')),
      ]);

      final error = createFailedToSendTransactionsError(result);

      final failedTransactions =
          error.context['failedTransactions']! as List<Map<String, Object?>>;
      expect(failedTransactions, hasLength(1));
      expect(failedTransactions[0]['index'], 1);
    });

    test('joins failure lines with positions and indicators', () {
      final result = sequentialTransactionPlanResult([
        parallelTransactionPlanResult([
          successfulSingleTransactionPlanResult(message('A'), {
            'signature': signature,
          }),
          failedSingleTransactionPlanResult(
            message('B'),
            createPreflightError(StateError('B failed'), preflightContext),
            {'signature': signature},
          ),
        ]),
        canceledSingleTransactionPlanResult(message('C')),
        sequentialTransactionPlanResult([
          failedSingleTransactionPlanResult(
            message('D'),
            StateError('D failed'),
            {'signature': signature},
          ),
          successfulSingleTransactionPlanResult(message('E'), {
            'signature': signature,
          }),
          failedSingleTransactionPlanResult(
            message('F'),
            createPreflightError(StateError('F failed'), preflightContext),
          ),
          failedSingleTransactionPlanResult(
            message('G'),
            StateError('G failed'),
          ),
        ]),
        canceledSingleTransactionPlanResult(message('H')),
      ]);

      final error = createFailedToSendTransactionsError(result);

      expect(
        getErrorMessage(error.code, error.context),
        'Failed to send transactions.\n'
        '[Tx #2 (preflight)] B failed\n'
        '[Tx #4 ($signature)] D failed\n'
        '[Tx #6 (preflight)] F failed\n'
        '[Tx #7] G failed\n',
      );
    });

    test('sets cause to the error when there is exactly one failure', () {
      final errorA = StateError('A failed');
      final result = sequentialTransactionPlanResult([
        failedSingleTransactionPlanResult(message('A'), errorA),
        canceledSingleTransactionPlanResult(message('B')),
      ]);

      final error = createFailedToSendTransactionsError(result);

      expect(error.context['cause'], same(errorA));
    });

    test('omits cause when there are multiple failures', () {
      final result = sequentialTransactionPlanResult([
        failedSingleTransactionPlanResult(message('A'), StateError('A failed')),
        failedSingleTransactionPlanResult(message('B'), StateError('B failed')),
      ]);

      final error = createFailedToSendTransactionsError(result);

      expect(error.context['cause'], isNull);
      expect(
        getErrorMessage(error.code, error.context),
        'Failed to send transactions.\n'
        '[Tx #1] A failed\n'
        '[Tx #2] B failed\n',
      );
    });

    test('appends logs for a single failing transaction', () {
      final innerError = SolanaError(
        SolanaErrorCode.transactionErrorInsufficientFundsForFee,
      );
      final preflightError = createPreflightError(innerError, preflightContext);
      final result = sequentialTransactionPlanResult([
        successfulSingleTransactionPlanResult(message('A'), {
          'signature': signature,
        }),
        failedSingleTransactionPlanResult(message('B'), preflightError),
      ]);

      final error = createFailedToSendTransactionsError(result);

      expect(
        getErrorMessage(error.code, error.context),
        'Failed to send transactions.\n'
        '[Tx #2 (preflight)] '
        '${getErrorMessage(innerError.code, innerError.context)}\n\n'
        'Logs:\n'
        '  > Program log: Instruction: Transfer\n'
        '  > Program failed: insufficient funds\n',
      );
    });

    test('omits logs when several transactions failed', () {
      final innerErrorA = SolanaError(
        SolanaErrorCode.transactionErrorInsufficientFundsForFee,
      );
      final innerErrorB = SolanaError(
        SolanaErrorCode.transactionErrorInsufficientFundsForFee,
      );
      final result = sequentialTransactionPlanResult([
        failedSingleTransactionPlanResult(
          message('A'),
          createPreflightError(innerErrorA, preflightContext),
        ),
        failedSingleTransactionPlanResult(
          message('B'),
          createPreflightError(innerErrorB, preflightContext),
        ),
      ]);

      final error = createFailedToSendTransactionsError(result);

      expect(
        getErrorMessage(error.code, error.context),
        'Failed to send transactions.\n'
        '[Tx #1 (preflight)] '
        '${getErrorMessage(innerErrorA.code, innerErrorA.context)}\n'
        '[Tx #2 (preflight)] '
        '${getErrorMessage(innerErrorB.code, innerErrorB.context)}\n',
      );
    });

    test('unwraps preflight errors in the failedTransactions entries', () {
      final innerError = SolanaError(
        SolanaErrorCode.transactionErrorInsufficientFundsForFee,
      );
      final preflightError = createPreflightError(innerError, preflightContext);
      final result = sequentialTransactionPlanResult([
        failedSingleTransactionPlanResult(message('A'), preflightError),
      ]);

      final error = createFailedToSendTransactionsError(result);

      final failedTransactions =
          error.context['failedTransactions']! as List<Map<String, Object?>>;
      expect(failedTransactions[0]['error'], same(innerError));
      expect(failedTransactions[0]['preflightData'], preflightContext);
      expect(failedTransactions[0]['logs'], preflightLogs);
    });

    test('reports the abort reason when all results were canceled', () {
      final abortReason = StateError('User aborted');
      final result = sequentialTransactionPlanResult([
        canceledSingleTransactionPlanResult(message('A')),
        canceledSingleTransactionPlanResult(message('B')),
      ]);

      final error = createFailedToSendTransactionsError(result, abortReason);

      expect(
        getErrorMessage(error.code, error.context),
        'Failed to send transactions. Canceled with abort reason: '
        'Bad state: User aborted',
      );
      expect(error.context['failedTransactions'], isEmpty);
      expect(error.context['cause'], same(abortReason));
    });

    test('handles a nested result tree with correct flat indices', () {
      final result = sequentialTransactionPlanResult([
        parallelTransactionPlanResult([
          successfulSingleTransactionPlanResult(message('A'), {
            'signature': signature,
          }),
          failedSingleTransactionPlanResult(
            message('B'),
            StateError('B failed'),
          ),
        ]),
        sequentialTransactionPlanResult([
          canceledSingleTransactionPlanResult(message('C')),
          failedSingleTransactionPlanResult(
            message('D'),
            StateError('D failed'),
          ),
        ]),
      ]);

      final error = createFailedToSendTransactionsError(result);

      final failedTransactions =
          error.context['failedTransactions']! as List<Map<String, Object?>>;
      expect(failedTransactions, hasLength(2));
      expect(failedTransactions[0]['index'], 1);
      expect(failedTransactions[1]['index'], 3);
      expect(error.context['transactionPlanResult'], same(result));
      expect(error.code, SolanaErrorCode.failedToSendTransactions);
    });
  });

  group('createFailedToSignTransactionError', () {
    test('unwraps preflight errors but omits the submission indicator', () {
      final innerError = SolanaError(
        SolanaErrorCode.transactionErrorInsufficientFundsForFee,
      );
      final preflightError = createPreflightError(innerError, preflightContext);
      final result = failedSingleTransactionPlanResult(
        message('A'),
        preflightError,
      );

      final error = createFailedToSignTransactionError(result);

      expect(error.context['cause'], same(innerError));
      expect(error.context['preflightData'], preflightContext);
      expect(error.context['logs'], preflightLogs);
      final messageText = getErrorMessage(error.code, error.context);
      expect(messageText, isNot(contains('(preflight)')));
      expect(messageText, startsWith('Failed to sign transaction: '));
      expect(messageText, contains('Logs:'));
      expect(messageText, contains('Program failed: insufficient funds'));
    });

    test('uses the plain error message without any indicator', () {
      final plainError = StateError('The user rejected the signing request');
      final result = failedSingleTransactionPlanResult(
        message('A'),
        plainError,
      );

      final error = createFailedToSignTransactionError(result);

      expect(error.context['cause'], same(plainError));
      expect(
        getErrorMessage(error.code, error.context),
        'Failed to sign transaction: The user rejected the signing request',
      );
    });

    test('lists failure positions without preflight or signature markers', () {
      final result = sequentialTransactionPlanResult([
        failedSingleTransactionPlanResult(
          message('A'),
          createPreflightError(StateError('A failed'), preflightContext),
          {'signature': signature},
        ),
        failedSingleTransactionPlanResult(message('B'), StateError('B failed')),
      ]);

      final error = createFailedToSignTransactionsError(result);

      expect(
        getErrorMessage(error.code, error.context),
        'Failed to sign transactions.\n'
        '[Tx #1] A failed\n'
        '[Tx #2] B failed\n',
      );
      expect(error.code, SolanaErrorCode.failedToSignTransactions);
    });

    test('cancels without an indicator and keeps the abort reason', () {
      final abortReason = StateError('User canceled');
      final result = canceledSingleTransactionPlanResult(message('A'));

      final error = createFailedToSignTransactionError(result, abortReason);

      expect(
        getErrorMessage(error.code, error.context),
        'Failed to sign transaction. Canceled with abort reason: '
        'Bad state: User canceled',
      );
      expect(error.code, SolanaErrorCode.failedToSignTransaction);
    });
  });

  group('createFailedToExecuteTransactionPlanError', () {
    test('carries the result, abort reason, and deprecated cause', () {
      final errorA = StateError('A failed');
      final result = sequentialTransactionPlanResult([
        failedSingleTransactionPlanResult(message('A'), errorA),
      ]);

      final error = createFailedToExecuteTransactionPlanError(result);

      expect(
        error.code,
        SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan,
      );
      expect(error.context['transactionPlanResult'], same(result));
      expect(error.context['cause'], same(errorA));
      expect(error.context['abortReason'], isNull);
    });
  });
}
