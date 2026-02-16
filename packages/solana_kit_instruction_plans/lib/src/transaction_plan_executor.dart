import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/src/transaction_plan.dart';
import 'package:solana_kit_instruction_plans/src/transaction_plan_result.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Executes a transaction plan and returns the execution results.
typedef TransactionPlanExecutor =
    Future<TransactionPlanResult> Function(TransactionPlan transactionPlan);

/// A function called whenever a transaction message must be sent to the
/// blockchain.
///
/// The [context] is a mutable map that can be used to incrementally store
/// useful data as execution progresses. The callback must return either a
/// [Signature] or a full [Transaction] object.
typedef ExecuteTransactionMessage =
    Future<Object> Function(
      Map<String, Object?> context,
      TransactionMessage message,
    );

/// Configuration object for creating a new transaction plan executor.
class TransactionPlanExecutorConfig {
  /// Creates a [TransactionPlanExecutorConfig].
  const TransactionPlanExecutorConfig({
    required this.executeTransactionMessage,
  });

  /// Called whenever a transaction message must be sent to the blockchain.
  final ExecuteTransactionMessage executeTransactionMessage;
}

/// Creates a new transaction plan executor based on the provided
/// configuration.
///
/// The executor will traverse the provided [TransactionPlan] sequentially
/// or in parallel, executing each transaction message using the
/// [TransactionPlanExecutorConfig.executeTransactionMessage] function.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan]
/// if any transaction in the plan fails to execute.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansNonDivisibleTransactionPlansNotSupported]
/// if the transaction plan contains non-divisible sequential plans.
TransactionPlanExecutor createTransactionPlanExecutor(
  TransactionPlanExecutorConfig config,
) {
  return (TransactionPlan plan) async {
    // Fail early if there are non-divisible sequential plans.
    _assertDivisibleSequentialPlansOnly(plan);

    var canceled = false;

    final transactionPlanResult = await _traverse(
      plan,
      config,
      () => canceled,
      () => canceled = true,
    );

    if (canceled) {
      final cause = _findErrorFromTransactionPlanResult(transactionPlanResult);
      throw SolanaError(
        SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan,
        {'cause': cause},
      );
    }

    return transactionPlanResult;
  };
}

Future<TransactionPlanResult> _traverse(
  TransactionPlan transactionPlan,
  TransactionPlanExecutorConfig config,
  bool Function() isCanceled,
  void Function() setCanceled,
) async {
  switch (transactionPlan) {
    case SequentialTransactionPlan():
      return _traverseSequential(
        transactionPlan,
        config,
        isCanceled,
        setCanceled,
      );
    case ParallelTransactionPlan():
      return _traverseParallel(
        transactionPlan,
        config,
        isCanceled,
        setCanceled,
      );
    case SingleTransactionPlan():
      return _traverseSingle(transactionPlan, config, isCanceled, setCanceled);
  }
}

Future<TransactionPlanResult> _traverseSequential(
  SequentialTransactionPlan transactionPlan,
  TransactionPlanExecutorConfig config,
  bool Function() isCanceled,
  void Function() setCanceled,
) async {
  if (!transactionPlan.divisible) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansNonDivisibleTransactionPlansNotSupported,
    );
  }

  final results = <TransactionPlanResult>[];

  for (final subPlan in transactionPlan.plans) {
    final result = await _traverse(subPlan, config, isCanceled, setCanceled);
    results.add(result);
  }

  return sequentialTransactionPlanResult(results);
}

Future<TransactionPlanResult> _traverseParallel(
  ParallelTransactionPlan transactionPlan,
  TransactionPlanExecutorConfig config,
  bool Function() isCanceled,
  void Function() setCanceled,
) async {
  final results = await Future.wait(
    transactionPlan.plans.map(
      (plan) => _traverse(plan, config, isCanceled, setCanceled),
    ),
  );
  return parallelTransactionPlanResult(results);
}

Future<TransactionPlanResult> _traverseSingle(
  SingleTransactionPlan transactionPlan,
  TransactionPlanExecutorConfig config,
  bool Function() isCanceled,
  void Function() setCanceled,
) async {
  final context = <String, Object?>{};
  if (isCanceled()) {
    return canceledSingleTransactionPlanResult(
      transactionPlan.message,
      context,
    );
  }

  try {
    final result = await config.executeTransactionMessage(
      context,
      transactionPlan.message,
    );
    if (result is String) {
      return successfulSingleTransactionPlanResult(transactionPlan.message, {
        ...context,
        'signature': Signature(result),
      });
    }
    return successfulSingleTransactionPlanResultFromTransaction(
      transactionPlan.message,
      result as Transaction,
      context,
    );
  } on Object catch (error) {
    setCanceled();
    // If the context contains a transaction but no signature, extract it.
    final contextWithSignature =
        context.containsKey('transaction') &&
            context['transaction'] is Transaction &&
            !context.containsKey('signature')
        ? {
            ...context,
            'signature': getSignatureFromTransaction(
              context['transaction']! as Transaction,
            ),
          }
        : context;
    return failedSingleTransactionPlanResult(
      transactionPlan.message,
      error,
      contextWithSignature,
    );
  }
}

Object? _findErrorFromTransactionPlanResult(TransactionPlanResult result) {
  switch (result) {
    case FailedSingleTransactionPlanResult(:final error):
      return error;
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

void _assertDivisibleSequentialPlansOnly(TransactionPlan transactionPlan) {
  switch (transactionPlan) {
    case SequentialTransactionPlan(:final divisible, :final plans):
      if (!divisible) {
        throw SolanaError(
          SolanaErrorCode
              .instructionPlansNonDivisibleTransactionPlansNotSupported,
        );
      }
      for (final subPlan in plans) {
        _assertDivisibleSequentialPlansOnly(subPlan);
      }
    case ParallelTransactionPlan(:final plans):
      for (final subPlan in plans) {
        _assertDivisibleSequentialPlansOnly(subPlan);
      }
    case SingleTransactionPlan():
      return;
  }
}

/// Wraps a transaction plan execution promise to return a
/// [TransactionPlanResult] even on execution failure.
///
/// When a transaction plan executor throws a
/// [SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan]
/// error, this helper catches it and returns the [TransactionPlanResult]
/// from the error context instead of throwing.
Future<TransactionPlanResult> passthroughFailedTransactionPlanExecution(
  Future<TransactionPlanResult> future,
) async {
  try {
    return await future;
  } on Object catch (error) {
    if (isSolanaError(
      error,
      SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan,
    )) {
      final solanaError = error as SolanaError;
      if (solanaError.context.containsKey('transactionPlanResult')) {
        return solanaError.context['transactionPlanResult']!
            as TransactionPlanResult;
      }
    }
    rethrow;
  }
}
