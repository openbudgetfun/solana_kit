import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// The result of executing a transaction plan.
///
/// This is structured as a recursive tree of results that mirrors the
/// structure of the original transaction plan.
sealed class TransactionPlanResult {
  /// Creates a [TransactionPlanResult].
  const TransactionPlanResult();

  /// The kind discriminator for this transaction plan result.
  String get kind;
}

/// The status of a single transaction plan result.
enum TransactionPlanResultStatus {
  /// The transaction was successfully executed.
  successful,

  /// The transaction failed during execution.
  failed,

  /// The transaction execution was canceled.
  canceled,
}

/// A result for a single transaction plan.
///
/// This represents the execution result of a single transaction plan and
/// contains the original transaction message along with its execution status.
sealed class SingleTransactionPlanResult extends TransactionPlanResult {
  /// Creates a [SingleTransactionPlanResult].
  const SingleTransactionPlanResult({
    required this.plannedMessage,
    required this.context,
  });

  /// The original transaction message from the plan.
  final TransactionMessage plannedMessage;

  /// Context data associated with this result.
  final Map<String, Object?> context;

  /// The execution status of this transaction.
  TransactionPlanResultStatus get status;

  @override
  String get kind => 'single';
}

/// A successful [SingleTransactionPlanResult].
///
/// The [context] will contain at least a `signature` field.
class SuccessfulSingleTransactionPlanResult
    extends SingleTransactionPlanResult {
  /// Creates a [SuccessfulSingleTransactionPlanResult].
  const SuccessfulSingleTransactionPlanResult({
    required super.plannedMessage,
    required super.context,
  });

  /// The signature of the successfully executed transaction.
  Signature get signature => context['signature']! as Signature;

  @override
  TransactionPlanResultStatus get status =>
      TransactionPlanResultStatus.successful;
}

/// A failed [SingleTransactionPlanResult].
class FailedSingleTransactionPlanResult extends SingleTransactionPlanResult {
  /// Creates a [FailedSingleTransactionPlanResult].
  const FailedSingleTransactionPlanResult({
    required super.plannedMessage,
    required this.error,
    required super.context,
  });

  /// The error that caused the transaction to fail.
  final Object error;

  @override
  TransactionPlanResultStatus get status => TransactionPlanResultStatus.failed;
}

/// A canceled [SingleTransactionPlanResult].
class CanceledSingleTransactionPlanResult extends SingleTransactionPlanResult {
  /// Creates a [CanceledSingleTransactionPlanResult].
  const CanceledSingleTransactionPlanResult({
    required super.plannedMessage,
    required super.context,
  });

  @override
  TransactionPlanResultStatus get status =>
      TransactionPlanResultStatus.canceled;
}

/// A result for a sequential transaction plan.
class SequentialTransactionPlanResult extends TransactionPlanResult {
  /// Creates a [SequentialTransactionPlanResult].
  const SequentialTransactionPlanResult({
    required this.plans,
    this.divisible = true,
  });

  /// The child results that were executed sequentially.
  final List<TransactionPlanResult> plans;

  /// Whether the plan was divisible.
  final bool divisible;

  @override
  String get kind => 'sequential';
}

/// A result for a parallel transaction plan.
class ParallelTransactionPlanResult extends TransactionPlanResult {
  /// Creates a [ParallelTransactionPlanResult].
  const ParallelTransactionPlanResult({required this.plans});

  /// The child results that were executed in parallel.
  final List<TransactionPlanResult> plans;

  @override
  String get kind => 'parallel';
}

// ---------------------------------------------------------------------------
// Constructor helpers
// ---------------------------------------------------------------------------

/// Creates a divisible [SequentialTransactionPlanResult].
SequentialTransactionPlanResult sequentialTransactionPlanResult(
  List<TransactionPlanResult> plans,
) => SequentialTransactionPlanResult(plans: plans);

/// Creates a non-divisible [SequentialTransactionPlanResult].
SequentialTransactionPlanResult nonDivisibleSequentialTransactionPlanResult(
  List<TransactionPlanResult> plans,
) => SequentialTransactionPlanResult(plans: plans, divisible: false);

/// Creates a [ParallelTransactionPlanResult].
ParallelTransactionPlanResult parallelTransactionPlanResult(
  List<TransactionPlanResult> plans,
) => ParallelTransactionPlanResult(plans: plans);

/// Creates a successful [SingleTransactionPlanResult] from a transaction
/// message and a [Transaction].
SuccessfulSingleTransactionPlanResult
successfulSingleTransactionPlanResultFromTransaction(
  TransactionMessage plannedMessage,
  Transaction transaction, [
  Map<String, Object?>? context,
]) {
  final sig = getSignatureFromTransaction(transaction);
  return SuccessfulSingleTransactionPlanResult(
    plannedMessage: plannedMessage,
    context: Map<String, Object?>.unmodifiable({
      ...?context,
      'signature': sig,
      'transaction': transaction,
    }),
  );
}

/// Creates a successful [SingleTransactionPlanResult] from a transaction
/// message and a context containing at least a `signature`.
SuccessfulSingleTransactionPlanResult successfulSingleTransactionPlanResult(
  TransactionMessage plannedMessage,
  Map<String, Object?> context,
) => SuccessfulSingleTransactionPlanResult(
  plannedMessage: plannedMessage,
  context: Map<String, Object?>.unmodifiable(context),
);

/// Creates a failed [SingleTransactionPlanResult] from a transaction
/// message and an error.
FailedSingleTransactionPlanResult failedSingleTransactionPlanResult(
  TransactionMessage plannedMessage,
  Object error, [
  Map<String, Object?>? context,
]) => FailedSingleTransactionPlanResult(
  plannedMessage: plannedMessage,
  error: error,
  context: Map<String, Object?>.unmodifiable(context ?? const {}),
);

/// Creates a canceled [SingleTransactionPlanResult] from a transaction
/// message.
CanceledSingleTransactionPlanResult canceledSingleTransactionPlanResult(
  TransactionMessage plannedMessage, [
  Map<String, Object?>? context,
]) => CanceledSingleTransactionPlanResult(
  plannedMessage: plannedMessage,
  context: Map<String, Object?>.unmodifiable(context ?? const {}),
);

// ---------------------------------------------------------------------------
// Type checks and assertions
// ---------------------------------------------------------------------------

/// Returns `true` if [value] is a [TransactionPlanResult].
bool isTransactionPlanResult(Object? value) => value is TransactionPlanResult;

/// Returns `true` if [plan] is a [SingleTransactionPlanResult].
bool isSingleTransactionPlanResult(TransactionPlanResult plan) =>
    plan is SingleTransactionPlanResult;

/// Asserts that [plan] is a [SingleTransactionPlanResult].
void assertIsSingleTransactionPlanResult(TransactionPlanResult plan) {
  if (plan is! SingleTransactionPlanResult) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
      {'actualKind': plan.kind, 'expectedKind': 'single'},
    );
  }
}

/// Returns `true` if [plan] is a successful [SingleTransactionPlanResult].
bool isSuccessfulSingleTransactionPlanResult(TransactionPlanResult plan) =>
    plan is SuccessfulSingleTransactionPlanResult;

/// Asserts that [plan] is a successful [SingleTransactionPlanResult].
void assertIsSuccessfulSingleTransactionPlanResult(TransactionPlanResult plan) {
  if (plan is! SuccessfulSingleTransactionPlanResult) {
    final actualKind = plan is SingleTransactionPlanResult
        ? '${plan.status.name} single'
        : plan.kind;
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
      {'actualKind': actualKind, 'expectedKind': 'successful single'},
    );
  }
}

/// Returns `true` if [plan] is a failed [SingleTransactionPlanResult].
bool isFailedSingleTransactionPlanResult(TransactionPlanResult plan) =>
    plan is FailedSingleTransactionPlanResult;

/// Asserts that [plan] is a failed [SingleTransactionPlanResult].
void assertIsFailedSingleTransactionPlanResult(TransactionPlanResult plan) {
  if (plan is! FailedSingleTransactionPlanResult) {
    final actualKind = plan is SingleTransactionPlanResult
        ? '${plan.status.name} single'
        : plan.kind;
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
      {'actualKind': actualKind, 'expectedKind': 'failed single'},
    );
  }
}

/// Returns `true` if [plan] is a canceled [SingleTransactionPlanResult].
bool isCanceledSingleTransactionPlanResult(TransactionPlanResult plan) =>
    plan is CanceledSingleTransactionPlanResult;

/// Asserts that [plan] is a canceled [SingleTransactionPlanResult].
void assertIsCanceledSingleTransactionPlanResult(TransactionPlanResult plan) {
  if (plan is! CanceledSingleTransactionPlanResult) {
    final actualKind = plan is SingleTransactionPlanResult
        ? '${plan.status.name} single'
        : plan.kind;
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
      {'actualKind': actualKind, 'expectedKind': 'canceled single'},
    );
  }
}

/// Returns `true` if [plan] is a [SequentialTransactionPlanResult].
bool isSequentialTransactionPlanResult(TransactionPlanResult plan) =>
    plan is SequentialTransactionPlanResult;

/// Asserts that [plan] is a [SequentialTransactionPlanResult].
void assertIsSequentialTransactionPlanResult(TransactionPlanResult plan) {
  if (plan is! SequentialTransactionPlanResult) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
      {'actualKind': plan.kind, 'expectedKind': 'sequential'},
    );
  }
}

/// Returns `true` if [plan] is a non-divisible
/// [SequentialTransactionPlanResult].
bool isNonDivisibleSequentialTransactionPlanResult(
  TransactionPlanResult plan,
) => plan is SequentialTransactionPlanResult && !plan.divisible;

/// Asserts that [plan] is a non-divisible
/// [SequentialTransactionPlanResult].
void assertIsNonDivisibleSequentialTransactionPlanResult(
  TransactionPlanResult plan,
) {
  if (plan is! SequentialTransactionPlanResult || plan.divisible) {
    final actualKind = plan is SequentialTransactionPlanResult && plan.divisible
        ? 'divisible sequential'
        : plan.kind;
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
      {'actualKind': actualKind, 'expectedKind': 'non-divisible sequential'},
    );
  }
}

/// Returns `true` if [plan] is a [ParallelTransactionPlanResult].
bool isParallelTransactionPlanResult(TransactionPlanResult plan) =>
    plan is ParallelTransactionPlanResult;

/// Asserts that [plan] is a [ParallelTransactionPlanResult].
void assertIsParallelTransactionPlanResult(TransactionPlanResult plan) {
  if (plan is! ParallelTransactionPlanResult) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult,
      {'actualKind': plan.kind, 'expectedKind': 'parallel'},
    );
  }
}

/// Returns `true` if the entire transaction plan result tree contains only
/// successful single transaction results.
bool isSuccessfulTransactionPlanResult(TransactionPlanResult plan) =>
    everyTransactionPlanResult(
      plan,
      (r) =>
          r is! SingleTransactionPlanResult ||
          r is SuccessfulSingleTransactionPlanResult,
    );

/// Asserts that the entire transaction plan result tree contains only
/// successful single transaction results.
void assertIsSuccessfulTransactionPlanResult(TransactionPlanResult plan) {
  if (!isSuccessfulTransactionPlanResult(plan)) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansExpectedSuccessfulTransactionPlanResult,
    );
  }
}

// ---------------------------------------------------------------------------
// Tree helpers
// ---------------------------------------------------------------------------

/// Finds the first transaction plan result in the tree that matches the
/// given [predicate].
TransactionPlanResult? findTransactionPlanResult(
  TransactionPlanResult transactionPlanResult,
  bool Function(TransactionPlanResult) predicate,
) {
  if (predicate(transactionPlanResult)) {
    return transactionPlanResult;
  }
  return switch (transactionPlanResult) {
    SingleTransactionPlanResult() => null,
    SequentialTransactionPlanResult(:final plans) ||
    ParallelTransactionPlanResult(
      :final plans,
    ) => _findInResultPlans(plans, predicate),
  };
}

TransactionPlanResult? _findInResultPlans(
  List<TransactionPlanResult> plans,
  bool Function(TransactionPlanResult) predicate,
) {
  for (final subResult in plans) {
    final found = findTransactionPlanResult(subResult, predicate);
    if (found != null) {
      return found;
    }
  }
  return null;
}

/// Retrieves the first failed transaction plan result from a transaction
/// plan result tree.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansFailedSingleTransactionPlanResultNotFound]
/// if no failed result is found.
FailedSingleTransactionPlanResult getFirstFailedSingleTransactionPlanResult(
  TransactionPlanResult transactionPlanResult,
) {
  final result = findTransactionPlanResult(
    transactionPlanResult,
    (r) => r is FailedSingleTransactionPlanResult,
  );

  if (result == null) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansFailedSingleTransactionPlanResultNotFound,
    );
  }

  return result as FailedSingleTransactionPlanResult;
}

/// Checks if every transaction plan result in the tree satisfies the given
/// [predicate].
bool everyTransactionPlanResult(
  TransactionPlanResult transactionPlanResult,
  bool Function(TransactionPlanResult) predicate,
) {
  if (!predicate(transactionPlanResult)) {
    return false;
  }
  return switch (transactionPlanResult) {
    SingleTransactionPlanResult() => true,
    SequentialTransactionPlanResult(:final plans) ||
    ParallelTransactionPlanResult(
      :final plans,
    ) => plans.every((p) => everyTransactionPlanResult(p, predicate)),
  };
}

/// Transforms a transaction plan result tree using a bottom-up approach.
TransactionPlanResult transformTransactionPlanResult(
  TransactionPlanResult transactionPlanResult,
  TransactionPlanResult Function(TransactionPlanResult) fn,
) => switch (transactionPlanResult) {
  SingleTransactionPlanResult() => fn(transactionPlanResult),
  SequentialTransactionPlanResult(:final plans, :final divisible) => fn(
    SequentialTransactionPlanResult(
      plans: plans.map((p) => transformTransactionPlanResult(p, fn)).toList(),
      divisible: divisible,
    ),
  ),
  ParallelTransactionPlanResult(:final plans) => fn(
    ParallelTransactionPlanResult(
      plans: plans.map((p) => transformTransactionPlanResult(p, fn)).toList(),
    ),
  ),
};

/// Retrieves all individual [SingleTransactionPlanResult] instances from a
/// transaction plan result tree.
List<SingleTransactionPlanResult> flattenTransactionPlanResult(
  TransactionPlanResult result,
) => switch (result) {
  SingleTransactionPlanResult() => [result],
  SequentialTransactionPlanResult(:final plans) ||
  ParallelTransactionPlanResult(
    :final plans,
  ) => plans.expand(flattenTransactionPlanResult).toList(),
};

/// A summary of a [TransactionPlanResult], categorizing transactions by
/// their execution status.
class TransactionPlanResultSummary {
  /// Creates a [TransactionPlanResultSummary].
  const TransactionPlanResultSummary({
    required this.successful,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.canceledTransactions,
  });

  /// Whether all transactions were successful.
  final bool successful;

  /// The list of successful transactions.
  final List<SuccessfulSingleTransactionPlanResult> successfulTransactions;

  /// The list of failed transactions.
  final List<FailedSingleTransactionPlanResult> failedTransactions;

  /// The list of canceled transactions.
  final List<CanceledSingleTransactionPlanResult> canceledTransactions;
}

/// Summarizes a [TransactionPlanResult] into a
/// [TransactionPlanResultSummary].
TransactionPlanResultSummary summarizeTransactionPlanResult(
  TransactionPlanResult result,
) {
  final successfulTransactions = <SuccessfulSingleTransactionPlanResult>[];
  final failedTransactions = <FailedSingleTransactionPlanResult>[];
  final canceledTransactions = <CanceledSingleTransactionPlanResult>[];

  final flattenedResults = flattenTransactionPlanResult(result);

  for (final singleResult in flattenedResults) {
    switch (singleResult) {
      case SuccessfulSingleTransactionPlanResult():
        successfulTransactions.add(singleResult);
      case FailedSingleTransactionPlanResult():
        failedTransactions.add(singleResult);
      case CanceledSingleTransactionPlanResult():
        canceledTransactions.add(singleResult);
    }
  }

  return TransactionPlanResultSummary(
    successful: failedTransactions.isEmpty && canceledTransactions.isEmpty,
    successfulTransactions: successfulTransactions,
    failedTransactions: failedTransactions,
    canceledTransactions: canceledTransactions,
  );
}
