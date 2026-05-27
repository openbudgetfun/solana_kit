import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_messages/src/compiled_transaction_message.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

/// Priority fee lamports occupies the lowest two config-mask bits.
const transactionConfigPriorityFeeLamportsBitMask = 3;

/// Compute unit limit occupies bit 2 of the config mask.
const transactionConfigComputeUnitLimitBitMask = 4;

/// Loaded accounts data size limit occupies bit 3 of the config mask.
const transactionConfigLoadedAccountsDataSizeLimitBitMask = 8;

/// Heap size occupies bit 4 of the config mask.
const transactionConfigHeapSizeBitMask = 16;

/// Returns [transactionMessage] with [config] merged into its v1 config.
TransactionMessage setTransactionMessageConfig(
  V1TransactionConfig config,
  TransactionMessage transactionMessage,
) {
  final current = transactionMessage.config;
  final merged = V1TransactionConfig(
    computeUnitLimit: config.computeUnitLimit ?? current?.computeUnitLimit,
    heapSize: config.heapSize ?? current?.heapSize,
    loadedAccountsDataSizeLimit:
        config.loadedAccountsDataSizeLimit ??
        current?.loadedAccountsDataSizeLimit,
    priorityFeeLamports:
        config.priorityFeeLamports ?? current?.priorityFeeLamports,
  );
  if (merged.isEmpty) {
    return current == null
        ? transactionMessage
        : transactionMessage.copyWith(clearConfig: true);
  }
  return current == merged
      ? transactionMessage
      : transactionMessage.copyWith(config: merged);
}

/// Returns v1 transaction config values in wire order for [config].
List<CompiledTransactionConfigValue> getTransactionConfigValues([
  V1TransactionConfig? config,
]) {
  final values = <CompiledTransactionConfigValue>[];
  final priorityFeeLamports = config?.priorityFeeLamports;
  final computeUnitLimit = config?.computeUnitLimit;
  final loadedAccountsDataSizeLimit = config?.loadedAccountsDataSizeLimit;
  final heapSize = config?.heapSize;
  if (priorityFeeLamports != null) {
    values.add(CompiledTransactionConfigValue.u64(priorityFeeLamports));
  }
  if (computeUnitLimit != null) {
    values.add(CompiledTransactionConfigValue.u32(computeUnitLimit));
  }
  if (loadedAccountsDataSizeLimit != null) {
    values.add(CompiledTransactionConfigValue.u32(loadedAccountsDataSizeLimit));
  }
  if (heapSize != null) {
    values.add(CompiledTransactionConfigValue.u32(heapSize));
  }
  return values;
}

/// Returns the v1 transaction config mask for [config].
int getTransactionConfigMask([V1TransactionConfig? config]) {
  var mask = 0;
  if (config?.priorityFeeLamports != null) {
    mask |= transactionConfigPriorityFeeLamportsBitMask;
  }
  if (config?.computeUnitLimit != null) {
    mask |= transactionConfigComputeUnitLimitBitMask;
  }
  if (config?.loadedAccountsDataSizeLimit != null) {
    mask |= transactionConfigLoadedAccountsDataSizeLimitBitMask;
  }
  if (config?.heapSize != null) {
    mask |= transactionConfigHeapSizeBitMask;
  }
  return mask;
}

/// Returns true when [mask] indicates a priority fee value.
bool transactionConfigMaskHasPriorityFee(int mask) {
  final priorityFeeBits = mask & transactionConfigPriorityFeeLamportsBitMask;
  if (priorityFeeBits == 1 || priorityFeeBits == 2) {
    throw SolanaError(
      SolanaErrorCode.transactionInvalidConfigMaskPriorityFeeBits,
      {'mask': mask},
    );
  }
  return priorityFeeBits == transactionConfigPriorityFeeLamportsBitMask;
}

/// Returns true when [mask] indicates a compute unit limit value.
bool transactionConfigMaskHasComputeUnitLimit(int mask) =>
    (mask & transactionConfigComputeUnitLimitBitMask) != 0;

/// Returns true when [mask] indicates a loaded accounts data size limit value.
bool transactionConfigMaskHasLoadedAccountsDataSizeLimit(int mask) =>
    (mask & transactionConfigLoadedAccountsDataSizeLimitBitMask) != 0;

/// Returns true when [mask] indicates a heap size value.
bool transactionConfigMaskHasHeapSize(int mask) =>
    (mask & transactionConfigHeapSizeBitMask) != 0;
