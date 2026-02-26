/// Plans a single transaction input.
typedef PlanTransactionFn<TInput, TPlan> =
    Future<TPlan> Function(
      TInput input,
    );

/// Sends a single transaction input.
typedef SendTransactionFn<TInput, TResult> =
    Future<TResult> Function(
      TInput input,
    );

/// Plans a batch of transaction inputs.
typedef PlanTransactionsFn<TInput, TPlan> =
    Future<List<TPlan>> Function(
      List<TInput> inputs,
    );

/// Sends a batch of transaction inputs.
typedef SendTransactionsFn<TInput, TResult> =
    Future<List<TResult>> Function(
      List<TInput> inputs,
    );

/// Minimal self-plan/send function bundle for generated program clients.
///
/// This keeps the API surface available while instruction planning packages
/// are introduced incrementally in Dart.
class SelfPlanAndSendFunctions<TInput, TPlan, TResult> {
  /// Creates a [SelfPlanAndSendFunctions] wrapper.
  ///
  /// If [planTransactions] or [sendTransactions] are omitted, batch behavior
  /// defaults to applying the single-item callback to each input and awaiting
  /// all results.
  SelfPlanAndSendFunctions({
    required PlanTransactionFn<TInput, TPlan> planTransaction,
    required SendTransactionFn<TInput, TResult> sendTransaction,
    PlanTransactionsFn<TInput, TPlan>? planTransactions,
    SendTransactionsFn<TInput, TResult>? sendTransactions,
  }) : _planTransaction = planTransaction,
       _sendTransaction = sendTransaction,
       _planTransactions = planTransactions,
       _sendTransactions = sendTransactions;

  final PlanTransactionFn<TInput, TPlan> _planTransaction;
  final SendTransactionFn<TInput, TResult> _sendTransaction;
  final PlanTransactionsFn<TInput, TPlan>? _planTransactions;
  final SendTransactionsFn<TInput, TResult>? _sendTransactions;

  /// Plans one transaction input.
  Future<TPlan> planTransaction(TInput input) {
    return _planTransaction(input);
  }

  /// Plans multiple transaction inputs.
  Future<List<TPlan>> planTransactions(List<TInput> inputs) async {
    if (_planTransactions != null) {
      return _planTransactions(inputs);
    }
    return Future.wait(inputs.map(_planTransaction));
  }

  /// Sends one transaction input.
  Future<TResult> sendTransaction(TInput input) {
    return _sendTransaction(input);
  }

  /// Sends multiple transaction inputs.
  Future<List<TResult>> sendTransactions(List<TInput> inputs) async {
    if (_sendTransactions != null) {
      return _sendTransactions(inputs);
    }
    return Future.wait(inputs.map(_sendTransaction));
  }
}

/// Creates a [SelfPlanAndSendFunctions] wrapper around planning/sending
/// callbacks.
SelfPlanAndSendFunctions<TInput, TPlan, TResult>
addSelfPlanAndSendFunctions<TInput, TPlan, TResult>({
  required PlanTransactionFn<TInput, TPlan> planTransaction,
  required SendTransactionFn<TInput, TResult> sendTransaction,
  PlanTransactionsFn<TInput, TPlan>? planTransactions,
  SendTransactionsFn<TInput, TResult>? sendTransactions,
}) {
  return SelfPlanAndSendFunctions<TInput, TPlan, TResult>(
    planTransaction: planTransaction,
    sendTransaction: sendTransaction,
    planTransactions: planTransactions,
    sendTransactions: sendTransactions,
  );
}
