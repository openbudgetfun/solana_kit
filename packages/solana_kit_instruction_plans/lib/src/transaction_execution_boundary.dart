// ignore_for_file: public_member_api_docs
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/src/instruction_plan.dart';
import 'package:solana_kit_instruction_plans/src/transaction_plan.dart';
import 'package:solana_kit_instruction_plans/src/transaction_plan_executor.dart';
import 'package:solana_kit_instruction_plans/src/transaction_plan_result.dart';
import 'package:solana_kit_instruction_plans/src/transaction_planner.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Signs a compiled transaction message before submission.
typedef SignTransactionMessage =
    Future<Transaction> Function(TransactionMessage message);

/// Sends a signed transaction and returns its signature.
typedef SendSignedTransaction = Future<Signature> Function(Transaction transaction);

/// Creates a transaction execution boundary that accepts an instruction plan
/// and returns a structured execution outcome.
typedef TransactionExecutionBoundary =
    Future<TransactionExecutionOutcome> Function(InstructionPlan instructionPlan);

/// High-level execution stages for transaction workflows.
enum TransactionExecutionFailureStage {
  /// Failed while planning messages from an instruction plan.
  planning,

  /// Failed while signing a transaction message.
  signing,

  /// Failed while sending a signed transaction.
  sending,

  /// Failed while traversing or aggregating execution results.
  execution,
}

/// Base type for higher-level transaction execution results.
sealed class TransactionExecutionOutcome {
  const TransactionExecutionOutcome();
}

/// Successful higher-level execution result.
class SuccessfulTransactionExecution extends TransactionExecutionOutcome {
  const SuccessfulTransactionExecution({
    required this.transactionPlan,
    required this.transactionPlanResult,
  });

  /// The planned transaction tree that was executed.
  final TransactionPlan transactionPlan;

  /// The execution result tree.
  final TransactionPlanResult transactionPlanResult;
}

/// Failed higher-level execution result.
class FailedTransactionExecution extends TransactionExecutionOutcome {
  const FailedTransactionExecution({
    required this.stage,
    required this.error,
    this.transactionPlan,
    this.transactionPlanResult,
  });

  /// The stage that failed.
  final TransactionExecutionFailureStage stage;

  /// The underlying error or failure object.
  final Object error;

  /// The planned transaction tree, if planning succeeded.
  final TransactionPlan? transactionPlan;

  /// The execution result tree, if execution started.
  final TransactionPlanResult? transactionPlanResult;
}

/// Configuration for a higher-level transaction execution boundary.
class TransactionExecutionBoundaryConfig {
  const TransactionExecutionBoundaryConfig({
    required this.planTransactions,
    required this.signTransactionMessage,
    required this.sendSignedTransaction,
  });

  /// Plans transaction messages from an instruction plan.
  final TransactionPlanner planTransactions;

  /// Signs each transaction message before submission.
  final SignTransactionMessage signTransactionMessage;

  /// Sends a signed transaction and returns its signature.
  final SendSignedTransaction sendSignedTransaction;
}

/// Convenience configuration for execution boundaries that resolve signers and
/// create a planner internally.
class SigningTransactionExecutionBoundaryConfig {
  const SigningTransactionExecutionBoundaryConfig({
    required this.createTransactionMessage,
    required this.signers,
    required this.sendSignedTransaction,
    this.onTransactionMessageUpdated,
  });

  /// Creates a fresh transaction message with fee payer and lifetime data.
  final CreateTransactionMessage createTransactionMessage;

  /// Optional transaction message update hook used during planning.
  final OnTransactionMessageUpdated? onTransactionMessageUpdated;

  /// Signers used to compile and sign planned messages.
  final List<Object> signers;

  /// Sends a signed transaction and returns its signature.
  final SendSignedTransaction sendSignedTransaction;
}

/// Creates a higher-level execution boundary from explicit planning, signing,
/// and sending functions.
TransactionExecutionBoundary createTransactionExecutionBoundary(
  TransactionExecutionBoundaryConfig config,
) {
  final executor = createTransactionPlanExecutor(
    TransactionPlanExecutorConfig(
      executeTransactionMessage: (context, message) async {
        final Transaction transaction;
        try {
          transaction = await config.signTransactionMessage(message);
          context['transaction'] = transaction;
        } on Object catch (error) {
          throw _TransactionExecutionStageError(
            TransactionExecutionFailureStage.signing,
            error,
          );
        }

        try {
          final signature = await config.sendSignedTransaction(transaction);
          context['signature'] = signature;
          return transaction;
        } on Object catch (error) {
          throw _TransactionExecutionStageError(
            TransactionExecutionFailureStage.sending,
            error,
          );
        }
      },
    ),
  );

  return (instructionPlan) async {
    final TransactionPlan transactionPlan;
    try {
      transactionPlan = await config.planTransactions(instructionPlan);
    } on Object catch (error) {
      return FailedTransactionExecution(
        stage: TransactionExecutionFailureStage.planning,
        error: error,
      );
    }

    try {
      final transactionPlanResult = await executor(transactionPlan);
      return SuccessfulTransactionExecution(
        transactionPlan: transactionPlan,
        transactionPlanResult: transactionPlanResult,
      );
    } on Object catch (error) {
      TransactionPlanResult? transactionPlanResult;
      if (isSolanaError(
        error,
        SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan,
      )) {
        final solanaError = error as SolanaError;
        final value = solanaError.context['transactionPlanResult'];
        if (value is TransactionPlanResult) {
          transactionPlanResult = value;
        }
      }

      transactionPlanResult ??= await _passthroughExecutionFailure(error);

      final failure = _extractExecutionFailure(error, transactionPlanResult);
      return FailedTransactionExecution(
        stage: failure.stage,
        error: failure.error,
        transactionPlan: transactionPlan,
        transactionPlanResult: transactionPlanResult,
      );
    }
  };
}

/// Creates a higher-level execution boundary that resolves signers using the
/// existing transaction signing helpers.
TransactionExecutionBoundary createSigningTransactionExecutionBoundary(
  SigningTransactionExecutionBoundaryConfig config,
) {
  final planner = createTransactionPlanner(
    TransactionPlannerConfig(
      createTransactionMessage: config.createTransactionMessage,
      onTransactionMessageUpdated: config.onTransactionMessageUpdated,
    ),
  );

  return createTransactionExecutionBoundary(
    TransactionExecutionBoundaryConfig(
      planTransactions: planner,
      signTransactionMessage: (message) {
        return signTransactionWithSigners(
          config.signers,
          compileTransaction(message),
        );
      },
      sendSignedTransaction: config.sendSignedTransaction,
    ),
  );
}

_ExecutionFailure _extractExecutionFailure(
  Object error,
  TransactionPlanResult? transactionPlanResult,
) {
  final firstError = transactionPlanResult == null
      ? error
      : _findFirstSingleTransactionError(transactionPlanResult) ?? error;

  if (firstError is _TransactionExecutionStageError) {
    return _ExecutionFailure(firstError.stage, firstError.error);
  }

  if (error is SolanaError) {
    final abortReason = error.context['abortReason'];
    if (abortReason is _TransactionExecutionStageError) {
      return _ExecutionFailure(abortReason.stage, abortReason.error);
    }
  }

  return _ExecutionFailure(
    TransactionExecutionFailureStage.execution,
    firstError,
  );
}

Object? _findFirstSingleTransactionError(TransactionPlanResult result) {
  switch (result) {
    case FailedSingleTransactionPlanResult(:final error):
      return error;
    case SingleTransactionPlanResult():
      return null;
    case SequentialTransactionPlanResult(:final plans):
    case ParallelTransactionPlanResult(:final plans):
      for (final plan in plans) {
        final error = _findFirstSingleTransactionError(plan);
        if (error != null) {
          return error;
        }
      }
      return null;
  }
}

Future<TransactionPlanResult?> _passthroughExecutionFailure(Object error) async {
  try {
    return await passthroughFailedTransactionPlanExecution(
      Future<TransactionPlanResult>.error(error),
    );
  } on Object {
    return null;
  }
}

class _ExecutionFailure {
  const _ExecutionFailure(this.stage, this.error);

  final TransactionExecutionFailureStage stage;
  final Object error;
}

class _TransactionExecutionStageError implements Exception {
  const _TransactionExecutionStageError(this.stage, this.error);

  final TransactionExecutionFailureStage stage;
  final Object error;

  @override
  String toString() => error.toString();
}
