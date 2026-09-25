import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart' as rpc_types;
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// The largest value a `u32` can hold.
final BigInt _maxU32 = BigInt.from(4294967295);

/// The maximum number of bytes of account data a transaction may load.
///
/// From Agave's `execution_budget.rs`. Used as the simulation ceiling so the
/// estimate reflects the work the transaction does rather than the budget it
/// was given. `64 MiB`.
const int maxLoadedAccountsDataSizeLimit = 64 * 1024 * 1024;

/// Configuration for [estimateResourceLimitsFactory].
class EstimateResourceLimitsFactoryConfig {
  /// Creates an [EstimateResourceLimitsFactoryConfig].
  const EstimateResourceLimitsFactoryConfig({required this.rpc});

  /// The RPC client used to simulate the transaction.
  final Rpc rpc;
}

/// Configuration for a single resource-limit estimation call.
class EstimateResourceLimitsConfig {
  /// Creates an [EstimateResourceLimitsConfig].
  const EstimateResourceLimitsConfig({
    this.abortSignal,
    this.commitment,
    this.minContextSlot,
  });

  /// Aborts the in-flight simulation when completed.
  final Future<void>? abortSignal;

  /// Simulates the transaction as of the highest slot that has reached this
  /// level of commitment.
  final rpc_types.Commitment? commitment;

  /// Prevents accessing stale data by requiring the node to be at or beyond
  /// this slot.
  final rpc_types.Slot? minContextSlot;
}

/// A function that estimates resource limits, optionally configured per call.
///
/// This is assignable to the narrower `EstimateResourceLimits` typedef in
/// `solana_kit_transaction_messages`, so an estimator produced here can be
/// handed straight to `estimateAndSetResourceLimitsFactory`.
typedef EstimateResourceLimitsWithConfig =
    Future<ResourceLimitsEstimate> Function(
      TransactionMessage transactionMessage, [
      EstimateResourceLimitsConfig? config,
    ]);

/// Returns a function that estimates the resource limits required by a
/// transaction message by simulating it.
///
/// The estimator sets the compute unit limit to the maximum (`1400000`) and,
/// for version 1 messages, the loaded accounts data size limit to the maximum
/// (`67108864`) before simulating, so the simulation does not fail from
/// resource exhaustion. For blockhash-lifetime transactions the RPC is asked to
/// replace the blockhash during simulation, so any blockhash value works; for
/// durable nonce transactions the real nonce is used, because replacing it
/// would invalidate the nonce.
///
/// Version 1 messages require both limits, so the estimator throws
/// [SolanaErrorCode.transactionFailedToEstimateLoadedAccountsDataSizeLimit]
/// when the node omits `loadedAccountsDataSize`. Legacy and version 0 messages
/// report it only when the node supplies it.
///
/// A simulation that fails for transaction reasons throws
/// [SolanaErrorCode.transactionFailedWhenSimulatingToEstimateResourceLimits]
/// with the decoded transaction error as `cause`. Any other failure throws
/// [SolanaErrorCode.transactionFailedToEstimateComputeLimit], also carrying the
/// original error as `cause`, which `unwrapSimulationError` can retrieve.
///
/// This lives in the umbrella package rather than in
/// `solana_kit_transaction_messages` because it needs both an RPC client and
/// the transaction compiler, and neither package can depend on the other.
///
/// ```dart
/// final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
/// final estimate = estimateResourceLimitsFactory(
///   EstimateResourceLimitsFactoryConfig(rpc: rpc),
/// );
/// final limits = await estimate(message);
/// print(limits.computeUnitLimit);
/// ```
EstimateResourceLimitsWithConfig estimateResourceLimitsFactory(
  EstimateResourceLimitsFactoryConfig factoryConfig,
) {
  final rpc = factoryConfig.rpc;

  return (
    TransactionMessage transactionMessage, [
    EstimateResourceLimitsConfig? config,
  ]) async {
    final replaceRecentBlockhash =
        !isTransactionMessageWithDurableNonceLifetime(transactionMessage);
    final isDataSizeRequired =
        transactionMessage.version == TransactionVersion.v1;

    // Simulate with every limit maxed so the estimate reflects the work the
    // transaction actually does rather than the budget it was given.
    var prepared = setTransactionMessageComputeUnitLimit(
      maxComputeUnitLimit,
      transactionMessage,
    );
    if (isDataSizeRequired) {
      prepared = setTransactionMessageLoadedAccountsDataSizeLimit(
        maxLoadedAccountsDataSizeLimit,
        prepared,
      );
    }

    final Object? response;
    try {
      final wireBytes = getBase64EncodedWireTransaction(
        compileTransaction(prepared),
      );
      final abortSignal = config?.abortSignal;
      response = await rpc
          .simulateTransaction(
            wireBytes,
            SimulateTransactionConfig(
              commitment: config?.commitment,
              encoding: rpc_types.WireTransactionEncoding.base64,
              minContextSlot: config?.minContextSlot,
              replaceRecentBlockhash: replaceRecentBlockhash,
              sigVerify: false,
            ),
          )
          .send(
            abortSignal == null
                ? null
                : RpcSendOptions(abortSignal: abortSignal),
          );
    } on Object catch (error) {
      // A transport or JSON-RPC failure carries no simulation result to
      // inspect, so it collapses into the generic estimation failure. The
      // original error stays reachable through `cause`.
      throw SolanaError(
        SolanaErrorCode.transactionFailedToEstimateComputeLimit,
        {'cause': error},
      );
    }

    final result = switch (response) {
      {'value': final Map<Object?, Object?> value} => value,
      _ => throw SolanaError(
        SolanaErrorCode.transactionFailedToEstimateComputeLimit,
      ),
    };

    final unitsConsumed = switch (result['unitsConsumed']) {
      final BigInt units => units,
      final int units => BigInt.from(units),
      _ => null,
    };
    if (unitsConsumed == null) {
      throw SolanaError(
        SolanaErrorCode.transactionFailedToEstimateComputeLimit,
      );
    }

    final loadedAccountsDataSize = switch (result['loadedAccountsDataSize']) {
      final int size => size,
      final BigInt size => size.toInt(),
      _ => null,
    };
    if (isDataSizeRequired && loadedAccountsDataSize == null) {
      throw SolanaError(
        SolanaErrorCode.transactionFailedToEstimateLoadedAccountsDataSizeLimit,
      );
    }

    // A transaction-level failure is reported in `err` rather than thrown, so
    // the limits above are already validated before this check runs.
    final transactionError = result['err'];
    if (transactionError != null) {
      throw SolanaError(
        SolanaErrorCode.transactionFailedWhenSimulatingToEstimateResourceLimits,
        {'cause': getSolanaErrorFromTransactionError(transactionError)},
      );
    }

    // Downcast the 64-bit counter, capping at the u32 ceiling the runtime
    // accepts for a compute unit limit.
    final computeUnitLimit = unitsConsumed > _maxU32
        ? _maxU32.toInt()
        : unitsConsumed.toInt();

    return ResourceLimitsEstimate(
      computeUnitLimit: computeUnitLimit,
      loadedAccountsDataSizeLimit: loadedAccountsDataSize,
    );
  };
}
