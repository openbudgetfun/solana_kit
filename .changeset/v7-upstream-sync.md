---
"solana_kit_errors": minor
"solana_kit_codecs_data_structures": minor
"solana_kit_instruction_plans": minor
"solana_kit_rpc_types": minor
"solana_kit": minor
"solana_kit_subscribable": minor
"solana_kit_rpc_spec": minor
"solana_kit_rpc_parsed_types": minor
"solana_kit_rpc_transformers": patch
"solana_kit_rpc_api": patch
"solana_kit_address_constants": patch
"solana_kit_rpc_subscriptions": patch
"solana_kit_associated_token_account": patch
"solana_kit_transaction_introspection": minor
---

# @solana/kit v7.0.0 upstream sync (foundational breaking changes)

Ports the foundational breaking changes from `@solana/kit` v7.0.0:

- **solana_kit_errors**: new `transactionIntrospection` error domain + codes
  (`transactionFailedToDecompileInstructionAccountIndexOutOfRange`,
  `transactionIntrospectionCannotDecodeJsonParsedTransaction`,
  `transactionIntrospectionUnrecognizedGetTransactionResponse`) and
  instruction-plans max-instructions codes
  (`instructionPlansInvalidMaxInstructionsPerTransaction`,
  `instructionPlansMaxInstructionsPerTransactionExceeded`).
- **solana_kit_codecs_data_structures**: `createDependentStructDecoder`
  fluent builder for structs whose later fields depend on earlier decoded
  values.
- **solana_kit_instruction_plans**: configurable
  `maxInstructionsPerTransaction` (default 16, limit 64) on
  `TransactionPlannerConfig`, individual `TransactionPlanner` invocations, and
  `MessagePacker`; invocation-specific planner values take precedence without
  leaking to later calls.
- **solana_kit_rpc_types**: `isSolanaRpcResponse` runtime guard.
- **solana_kit**: removed the local `getMinimumBalanceForRentExemption`
  helper (rent exemption is becoming dynamic; use the RPC method instead).
- **solana_kit_subscribable**: `ReactiveStreamStore` v7 rewrite —
  caller-driven `connect()`/`reset()`/`withSignal()`, starts `idle`,
  collapses `retrying` into `loading` (stale-while-revalidate), renames
  `getUnifiedState()` → `getState()`; removed `retry()`, value-only
  `getState()`, `getError()`. `ReactiveActionStore` now passes a fresh
  `CancellationToken` to every action, cancels superseded/reset/disposed
  dispatches, suppresses late outcomes, exposes caller cancellation through
  `withSignal()`, and preserves stale results and errors while running.
- **solana_kit_transaction_introspection**: new first-class package porting
  `@solana/transaction-introspection` — RPC transaction decoding, instruction and
  inner-instruction extraction, loaded-address resolution, and instruction
  walking helpers; re-exported from the `solana_kit` umbrella.
- **solana_kit_rpc_parsed_types** / **solana_kit_rpc_transformers** /
  **solana_kit_rpc_api**: Agave 4.1.0 parsed-account types — vote
  commissions/latency as `int` (not `BigInt`); rent sysvar union
  (`lamportsPerByte` vs deprecated `burnPercent`/`exemptionThreshold`/
  `lamportsPerByteYear`); stake `warmupCooldownRate` optional; config
  `slashPenalty`/`warmupCooldownRate` deprecated; keep vote commissions
  and latency as `int` in the numeric-keypath allow-lists.

Migration: `getMinimumBalanceForRentExemption(space)` →
`rpc.getMinimumBalanceForRentExemption(space).send()`; `store.retry()` →
`store.connect()`; `store.getUnifiedState()` → `store.getState()`; the
deprecated `ReactiveStore`/`createReactiveStoreFromStreams` →
`createReactiveStreamStore`; reactive actions must migrate from
`(args) async => result` to `(signal, args) async => result`.
