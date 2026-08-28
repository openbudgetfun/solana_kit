---
"solana_kit": minor
"solana_kit_errors": minor
"solana_kit_instruction_plans": minor
"solana_kit_rpc_transformers": major
"solana_kit_transaction_messages": major
"solana_kit_transactions": major
---

# Sync upstream `@solana/kit` v8.1.0

Tracks upstream APIs and behavior through `v8.1.0`:

- **`solana_kit_transaction_messages` (breaking)**: removed the deprecated compute-unit-limit helpers `fillTransactionMessageProvisoryComputeUnitLimit` and `estimateAndSetComputeUnitLimitFactory`, matching upstream `@solana/kit`'s removal of the deprecated `@solana/kit` estimation helpers (#1948). Use `fillTransactionMessageProvisoryResourceLimits` and `estimateAndSetResourceLimitsFactory` instead, which additionally reserve and set the loaded accounts data size limit for version 1 transactions. `setTransactionMessageComputeUnitLimit` and `setTransactionMessageConfig` now reject compute unit limits the runtime will not honor — an integer outside `[0, 1400000]` — throwing `SolanaErrorCode.transactionComputeUnitLimitOutOfRange`, and reject invalid heap sizes — not a multiple of 1024 bytes in `[32768, 262144]` — throwing `SolanaErrorCode.transactionInvalidHeapSize` (upstream #1972). Added the upstream `heap-size.ts` module as `getTransactionMessageHeapSize`/`setTransactionMessageHeapSize` with the same validation, and `resource_limit_validation.dart` with `assertIsValidComputeUnitLimit`/`assertIsValidHeapSize`, `minHeapSize`, `maxHeapSize`, and `heapSizeMultipleOf`. Decoding is unaffected: `decompileTransactionMessage` still returns messages carrying out-of-range values.

  Migration:
  - `fillTransactionMessageProvisoryComputeUnitLimit(m)` → `fillTransactionMessageProvisoryResourceLimits(m)`.
  - `estimateAndSetComputeUnitLimitFactory(estimate)` → `estimateAndSetResourceLimitsFactory(estimateResourceLimitsFactory(estimate))`.
- **`solana_kit_transactions` (breaking)**: removed the fixed-size constants `transactionPacketSize`, `transactionPacketHeader`, and `transactionSizeLimit`, matching upstream's removal of `TRANSACTION_PACKET_SIZE`, `TRANSACTION_PACKET_HEADER`, and `TRANSACTION_SIZE_LIMIT` (#1948). Use `getTransactionSizeLimit` to derive the limit for a specific transaction, or the per-version constants `legacyTransactionSizeLimit` (1232) and `v1TransactionSizeLimit` (4096).

  Migration: `TRANSACTION_SIZE_LIMIT - getTransactionSize(t)` → `getTransactionSizeLimit(t) - getTransactionSize(t)`.
- `solana_kit_errors`: added the `failedToSignTransaction` (13) and `failedToSignTransactions` (14) error codes with upstream messages, plus the transaction codes `transactionComputeUnitLimitOutOfRange` (5663039) and `transactionInvalidHeapSize` (5663040) (upstream #1902, #1972).
- `solana_kit_instruction_plans`: added `createFailedToSendTransactionError`, `createFailedToSendTransactionsError`, `createFailedToSignTransactionError`, `createFailedToSignTransactionsError`, and `createFailedToExecuteTransactionPlanError`, mirroring upstream `@solana/instruction-plans`' `transaction-plan-errors.ts` (#1902, #1434). The signing factories carry the same non-enumerable `transactionPlanResult` and optional `logs`/`preflightData` context as their sending counterparts, but the message includes no submission-location indicator because signing never submits. The executor now throws through `createFailedToExecuteTransactionPlanError`.
- `solana_kit`: added the `ClientWithTransactionSending` and `ClientWithTransactionSigning` client interfaces, mirroring upstream `@solana/plugin-interfaces` (#1899). `signTransaction`/`signTransactions` accept the same flexible inputs as their sending counterparts and return signed transactions without submitting them. Sending results guarantee a signature-bearing `context`; signing makes no default guarantee about the context, matching the upstream `TContext` parameterization (adapted to Dart's map-based result contexts).
- **`solana_kit_rpc_transformers` (breaking)**: removed `getBigIntDowncastRequestTransformer`, matching upstream #1948. It was no longer used by the default Solana RPC request transformer: the Solana RPC transport serializes `BigInt` values losslessly as large integer literals via `stringifyJsonWithBigInts`, and Agave parses JSON integers across the full `u64` range without precision loss, so downcasting `BigInt`s to (potentially lossy) `int`s is unnecessary. `getDefaultRequestTransformerForSolanaRpc` no longer downcasts; if you still need this behavior, recreate it with `getTreeWalkerRequestTransformer` and a visitor that replaces `BigInt` nodes with `int` values.
- `solana_kit_rpc_transformers`: the numeric allow-list keeps `transactionConfig.computeUnitLimit`, `transactionConfig.heapSize`, and `transactionConfig.loadedAccountsDataSizeLimit` from version 1 transaction responses as numbers instead of upcasting them to `BigInt` (upstream #1951).
- Documentation now tracks `@solana/kit` `v8.1.0`, and the reference pin in `config/reference-repos.json` moved to `bb54243d8a57` (tag `v8.1.0`).

Migration example:

```dart
// Before (removed):
// final estimate = estimateComputeUnitLimitFactory(rpc);
// var message = await estimateAndSetComputeUnitLimitFactory(estimate)(message);
// final freeBytes = transactionSizeLimit - getTransactionSize(transaction);

// After:
final estimate = estimateResourceLimitsFactory(rpc);
var message = await estimateAndSetResourceLimitsFactory(estimate)(message);
final freeBytes =
    getTransactionSizeLimit(transaction) - getTransactionSize(transaction);
```
