import 'package:solana_kit_transaction_messages/src/transaction_message.dart';
import 'package:solana_kit_transaction_messages/src/v1_transaction_config.dart';

/// Returns the priority fee in lamports currently set on a version 1
/// transaction message, or `null` if none is set.
///
/// The priority fee is a version 1 concept: it lives in the message config as
/// a total in lamports, so legacy and version 0 messages have none. Use
/// `setTransactionMessageComputeUnitPrice` from `solana_kit_compute_budget`
/// for those versions, which expresses a rate in microLamports per compute
/// unit instead.
BigInt? getTransactionMessagePriorityFeeLamports(
  TransactionMessage transactionMessage,
) {
  if (transactionMessage.version != TransactionVersion.v1) return null;
  return transactionMessage.config?.priorityFeeLamports;
}

/// Sets the total priority fee for a version 1 transaction message.
///
/// In version 1 transactions the priority fee is expressed as a total in
/// lamports — what you set is what you pay, regardless of the compute unit
/// limit.
///
/// Pass `null` as [priorityFeeLamports] to remove the fee. If removing it
/// leaves the config empty, the config is dropped from the message entirely so
/// the compiled message does not reserve space for an absent value.
///
/// Returns [transactionMessage] unchanged when the fee already has the
/// requested value.
TransactionMessage setTransactionMessagePriorityFeeLamports(
  BigInt? priorityFeeLamports,
  TransactionMessage transactionMessage,
) {
  if (transactionMessage.version != TransactionVersion.v1) {
    return transactionMessage;
  }

  final nextConfig = priorityFeeLamports == null
      ? transactionMessage.config?.copyWith(clearPriorityFeeLamports: true)
      : setTransactionMessageConfig(
          V1TransactionConfig(priorityFeeLamports: priorityFeeLamports),
          transactionMessage,
        ).config;

  if (nextConfig == null || nextConfig.isEmpty) {
    return transactionMessage.config == null
        ? transactionMessage
        : transactionMessage.copyWith(clearConfig: true);
  }

  if (transactionMessage.config == nextConfig) return transactionMessage;
  return transactionMessage.copyWith(config: nextConfig);
}
