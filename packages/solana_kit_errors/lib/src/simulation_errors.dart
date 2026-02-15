import 'package:solana_kit_errors/src/codes.dart';
import 'package:solana_kit_errors/src/error.dart';

/// Extracts the underlying cause from a simulation-related error.
///
/// When a transaction simulation fails, the error is often wrapped in a
/// simulation-specific [SolanaError]. This function unwraps such errors
/// by returning the `cause` property from the error's context, giving you
/// access to the actual error that triggered the simulation failure.
///
/// If the provided error is not a simulation-related error, it is returned
/// unchanged.
Object? unwrapSimulationError(Object? error) {
  const simulationCodes = [
    SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
    SolanaErrorCode.transactionFailedWhenSimulatingToEstimateComputeLimit,
  ];

  if (error is SolanaError &&
      simulationCodes.contains(error.code) &&
      error.context.containsKey('cause')) {
    return error.context['cause'];
  }

  return error;
}
