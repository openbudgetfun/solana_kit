import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/src/transaction_plan_result.dart';

/// Creates a [SolanaError] with the
/// [SolanaErrorCode.failedToSendTransaction] error code from a failed or
/// canceled [SingleTransactionPlanResult].
///
/// This is a high-level error designed for user-facing transaction send
/// failures. It unwraps simulation errors (such as preflight failures) to
/// expose the underlying transaction error as the `cause`, and extracts
/// preflight data and logs into the error context for easy access.
///
/// The error message includes an indicator showing whether the failure was a
/// preflight error or includes the on-chain transaction signature for easy
/// copy-pasting into block explorers.
///
/// {@template solana_kit_instruction_plans.failed_to_send_sign_error_example}
/// ```dart
/// final error = createFailedToSendTransactionError(failedResult);
/// print(error.context['causeMessage']);
/// // " (preflight): Insufficient funds for fee"
/// ```
/// {@endtemplate}
///
/// See also:
/// - [createFailedToSendTransactionsError]
/// - [createFailedToSignTransactionError]
SolanaError createFailedToSendTransactionError(
  SingleTransactionPlanResult result, [
  Object? abortReason,
]) {
  return SolanaError(
    SolanaErrorCode.failedToSendTransaction,
    _getSingleFailureContext(
      result,
      abortReason,
      includeSubmissionIndicator: true,
    ),
  );
}

/// Creates a [SolanaError] with the
/// [SolanaErrorCode.failedToSignTransaction] error code from a failed or
/// canceled [SingleTransactionPlanResult].
///
/// This is the signing counterpart to [createFailedToSendTransactionError],
/// designed for user-facing failures raised by executors that sign a
/// transaction without submitting it. It behaves identically — unwrapping
/// simulation errors to expose the underlying transaction error as the
/// `cause`, and extracting preflight data and logs into the error context —
/// because signing executors typically estimate resource limits by simulating
/// before they sign.
///
/// Unlike the sending variant, the message carries no indicator of where the
/// failure happened. That indicator locates a failure relative to network
/// submission — `(preflight)` before it, or the transaction signature after
/// it — and signing never submits, so neither applies. The `logs` and
/// `preflightData` context properties are still populated whenever a
/// simulation was responsible, and those logs still appear in the message, so
/// nothing is lost beyond the prefix.
///
/// See also:
/// - [createFailedToSignTransactionsError]
/// - [createFailedToSendTransactionError]
SolanaError createFailedToSignTransactionError(
  SingleTransactionPlanResult result, [
  Object? abortReason,
]) {
  return SolanaError(
    SolanaErrorCode.failedToSignTransaction,
    _getSingleFailureContext(
      result,
      abortReason,
      includeSubmissionIndicator: false,
    ),
  );
}

/// Creates a [SolanaError] with the
/// [SolanaErrorCode.failedToSendTransactions] error code from a
/// [TransactionPlanResult].
///
/// This is a high-level error designed for user-facing transaction send
/// failures involving multiple transactions. It walks the result tree,
/// unwraps simulation errors from each failure, and builds a
/// `failedTransactions` array pairing each failure with its unwrapped error,
/// logs, and preflight data.
///
/// The error message lists each failure with its position in the plan and an
/// indicator showing whether it was a preflight error or includes the
/// transaction signature. When all transactions were canceled, the message is
/// a single line.
///
/// See also:
/// - [createFailedToSendTransactionError]
/// - [createFailedToSignTransactionsError]
SolanaError createFailedToSendTransactionsError(
  TransactionPlanResult result, [
  Object? abortReason,
]) {
  return SolanaError(
    SolanaErrorCode.failedToSendTransactions,
    _getMultipleFailuresContext(
      result,
      abortReason,
      includeSubmissionIndicator: true,
    ),
  );
}

/// Creates a [SolanaError] with the
/// [SolanaErrorCode.failedToSignTransactions] error code from a
/// [TransactionPlanResult].
///
/// This is the signing counterpart to [createFailedToSendTransactionsError],
/// designed for user-facing failures raised by executors that sign several
/// transactions without submitting them. It walks the result tree, unwraps
/// simulation errors from each failure, and builds the same
/// `failedTransactions` array pairing each failure with its unwrapped error,
/// logs, and preflight data.
///
/// As with [createFailedToSignTransactionError], each line names only the
/// position of the failure in the plan. Nothing was submitted, so there is no
/// preflight to flag and no transaction signature worth quoting.
///
/// See also:
/// - [createFailedToSignTransactionError]
/// - [createFailedToSendTransactionsError]
SolanaError createFailedToSignTransactionsError(
  TransactionPlanResult result, [
  Object? abortReason,
]) {
  return SolanaError(
    SolanaErrorCode.failedToSignTransactions,
    _getMultipleFailuresContext(
      result,
      abortReason,
      includeSubmissionIndicator: false,
    ),
  );
}

/// Creates a [SolanaError] with the
/// [SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan] error code
/// from a [TransactionPlanResult].
///
/// This is a low-level error intended for custom transaction plan executor
/// authors. It attaches the full `transactionPlanResult` to the error context
/// so that callers can inspect execution details.
///
/// See also:
/// - [createFailedToSendTransactionError]
/// - [createFailedToSendTransactionsError]
SolanaError createFailedToExecuteTransactionPlanError(
  TransactionPlanResult result, [
  Object? abortReason,
]) {
  return SolanaError(
    SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan,
    {
      'abortReason': abortReason,
      // Deprecated: will be removed in a future version.
      'cause': _findErrorFromTransactionPlanResult(result) ?? abortReason,
      'transactionPlanResult': result,
    },
  );
}

Map<String, Object?> _getSingleFailureContext(
  SingleTransactionPlanResult result,
  Object? abortReason, {
  required bool includeSubmissionIndicator,
}) {
  String causeMessage;
  Object? cause;
  List<String>? logs;
  Map<String, Object?>? preflightData;

  switch (result) {
    case final FailedSingleTransactionPlanResult failed:
      final unwrapped = _unwrapErrorWithPreflightData(failed.error);
      logs = unwrapped.logs;
      preflightData = unwrapped.preflightData;
      cause = unwrapped.unwrappedError;
      final indicator = includeSubmissionIndicator
          ? _getFailedIndicator(
              preflightData != null,
              _getSignatureFromContext(result.context),
            )
          : '';
      causeMessage =
          '$indicator: '
          '${_errorMessage(unwrapped.unwrappedError)}${_formatLogSnippet(logs)}';
    case _:
      cause = abortReason;
      causeMessage = abortReason != null
          ? '. Canceled with abort reason: $abortReason'
          : ': Canceled';
  }

  return {
    'cause': cause,
    'causeMessage': causeMessage,
    'logs': logs,
    'preflightData': preflightData,
    'transactionPlanResult': result,
  };
}

Map<String, Object?> _getMultipleFailuresContext(
  TransactionPlanResult result,
  Object? abortReason, {
  required bool includeSubmissionIndicator,
}) {
  final flattenedResults = flattenTransactionPlanResult(result);

  final failedTransactions = <Map<String, Object?>>[];
  for (final (index, singleResult) in flattenedResults.indexed) {
    if (singleResult is! FailedSingleTransactionPlanResult) continue;
    final unwrapped = _unwrapErrorWithPreflightData(singleResult.error);
    failedTransactions.add({
      'error': unwrapped.unwrappedError,
      'index': index,
      'logs': unwrapped.logs,
      'preflightData': unwrapped.preflightData,
    });
  }

  String causeMessages;
  Object? cause;

  if (failedTransactions.isNotEmpty) {
    cause = failedTransactions.length == 1
        ? failedTransactions[0]['error']
        : null;
    final failureLines = failedTransactions.map((failure) {
      final index = failure['index']! as int;
      final preflightData = failure['preflightData'] as Map<String, Object?>?;
      final indicator = includeSubmissionIndicator
          ? _getFailedIndicator(
              preflightData != null,
              _getSignatureFromContext(flattenedResults[index].context),
            )
          : '';
      return '\n[Tx #${index + 1}$indicator] '
          '${_errorMessage(failure['error']!)}';
    }).join();
    final logSnippet = failedTransactions.length == 1
        ? _formatLogSnippet(failedTransactions[0]['logs'] as List<String>?)
        : '';
    causeMessages =
        '.$failureLines$logSnippet${logSnippet.isEmpty ? '\n' : ''}';
  } else {
    cause = abortReason;
    causeMessages = abortReason != null
        ? '. Canceled with abort reason: $abortReason'
        : ': Canceled';
  }

  return {
    'cause': cause,
    'causeMessages': causeMessages,
    'failedTransactions': List<Map<String, Object?>>.unmodifiable(
      failedTransactions,
    ),
    'transactionPlanResult': result,
  };
}

({
  List<String>? logs,
  Map<String, Object?>? preflightData,
  Object unwrappedError,
})
_unwrapErrorWithPreflightData(Object error) {
  const simulationCodes = [
    SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
    SolanaErrorCode.transactionFailedWhenSimulatingToEstimateComputeLimit,
  ];
  if (error is SolanaError && simulationCodes.contains(error.code)) {
    final preflightData = <String, Object?>{
      ...error.context,
    }..remove('cause');
    final logs = preflightData['logs'] as List<String>?;
    return (
      logs: logs,
      preflightData: preflightData,
      unwrappedError: error.context['cause'] ?? error,
    );
  }
  return (logs: null, preflightData: null, unwrappedError: error);
}

Object? _findErrorFromTransactionPlanResult(TransactionPlanResult result) {
  switch (result) {
    case final FailedSingleTransactionPlanResult failed:
      return failed.error;
    case SingleTransactionPlanResult():
      return null;
    case SequentialTransactionPlanResult(:final plans):
    case ParallelTransactionPlanResult(:final plans):
      for (final plan in plans) {
        final error = _findErrorFromTransactionPlanResult(plan);
        if (error != null) {
          return error;
        }
      }
      return null;
  }
}

String _formatLogSnippet(List<String>? logs) {
  if (logs == null || logs.isEmpty) return '';
  const maxLines = 8;
  final lastLines = logs.length > maxLines
      ? logs.sublist(logs.length - maxLines)
      : logs;
  final header = logs.length > maxLines
      ? '\n\nLogs (last $maxLines of ${logs.length}):'
      : '\n\nLogs:';
  return '$header\n${lastLines.map((line) => '  > $line\n').join()}';
}

/// Reads a signature out of an arbitrary result context.
///
/// Nothing guarantees that a context has a signature — an executor may
/// produce results for transactions it never submitted — so this narrows at
/// runtime rather than trusting the type.
String? _getSignatureFromContext(Map<String, Object?> context) {
  final signature = context['signature'];
  return signature is String ? signature : null;
}

String _getFailedIndicator(bool isPreflight, String? signature) {
  if (isPreflight) return ' (preflight)';
  if (signature != null) return ' ($signature)';
  return '';
}

String _errorMessage(Object error) {
  if (error is SolanaError) return getErrorMessage(error.code, error.context);
  if (error is StateError) return error.message;
  return error.toString();
}
