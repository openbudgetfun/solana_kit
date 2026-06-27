---
"solana_kit_errors": minor
"solana_kit_subscribable": minor
"solana_kit_rpc_spec": minor
"solana_kit_rpc_api": minor
"solana_kit_transaction_messages": minor
"solana_kit": patch
---

# Upstream @solana/kit 6.10.0 parity

Updates core packages to match upstream `@solana/kit` `6.10.0`:

- **solana_kit_errors**: Adds 6 new error codes from `@solana/errors` 6.10:
  `JSON_RPC__SERVER_ERROR_NO_SLOT_HISTORY` (-32021),
  `JSON_RPC__SERVER_ERROR_FILTER_TRANSACTION_NOT_FOUND` (-32020),
  `TRANSACTION__FAILED_TO_ESTIMATE_LOADED_ACCOUNTS_DATA_SIZE_LIMIT` (5663036),
  `TRANSACTION__FAILED_WHEN_SIMULATING_TO_ESTIMATE_RESOURCE_LIMITS` (5663037),
  `SUBSCRIBABLE__RETRY_NOT_SUPPORTED` (8195000),
  `WALLET__ACCOUNT_NOT_AVAILABLE` (8900003).
  Adds `subscribable` and `wallet` error domains. Updates
  `unwrapSimulationError` to treat resource-limit simulation failures as
  simulation errors.

- **solana_kit_subscribable**: Adds `ReactiveActionStore<TArgs, TResult>` with
  idle/running/success/error states, `dispatch`/`dispatchAsync`/`reset`.
  Adds `ReactiveStreamStore<T>` with loading/loaded/error/retrying states,
  `getUnifiedState` and `retry`. Mirrors upstream `@solana/subscribable` 6.10.

- **solana_kit_rpc_spec**: Adds `PendingRpcRequest.reactiveStore()` returning a
  `ReactiveActionStore` for reactive request dispatch.

- **solana_kit_rpc_api**: Adds `clientId` to `ClusterNode`. Documents `tpu` and
  `tpuForwards` as deprecated in favor of QUIC fields.

- **solana_kit_transaction_messages**: Adds resource-limit estimation helpers:
  `ResourceLimitsEstimate`, `estimateResourceLimitsFactory`,
  `estimateAndSetResourceLimitsFactory`,
  `fillTransactionMessageProvisoryResourceLimits`,
  `getTransactionMessageLoadedAccountsDataSizeLimit`,
  `setTransactionMessageLoadedAccountsDataSizeLimit`.