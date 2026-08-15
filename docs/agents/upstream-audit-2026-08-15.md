# Upstream audit — 2026-08-15

## Scope

Upstream parity sync from `@solana/kit` `7.0.0` → `7.1.0` (released
2026-08-14). Excludes `@solana/react`, which is not ported to Dart.

Reference pin bumped in `config/reference-repos.json`:
`anza-xyz/kit` `checkedCommit` `6cd177b14bed` → `661554c4e85f` (tag `v7.1.0`).
`versions.json` `@solana/kit` `7.0.0` → `7.1.0`.

## v7.1.0 changelog → Dart package mapping

### Minor Changes

| Upstream change                                                                                                                                                                 | Dart package                                        | Status                           |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- | -------------------------------- |
| `@solana/subscribable` `bridgeStoreToAsyncIterable` + `SOLANA_ERROR__SUBSCRIBABLE__STREAM_CLOSED_WITHOUT_ERROR`                                                                 | `solana_kit_subscribable`, `solana_kit_errors`      | errors ✅ ; subscribable pending |
| `@solana/offchain-messages` `assertOffchainMessageV1Equal` + `SOLANA_ERROR__OFFCHAIN_MESSAGE__CONTENT_DOES_NOT_MATCH_EXPECTED` / `__REQUIRED_SIGNATORIES_DO_NOT_MATCH_EXPECTED` | `solana_kit_offchain_messages`, `solana_kit_errors` | errors ✅ ; offchain pending     |
| `@solana/instruction-plans` `createTransactionPlanExecutor` callback may return result context (returning `Signature`/`Transaction` deprecated)                                 | `solana_kit_instruction_plans`                      | pending                          |
| `@solana/kit` `createClientWithGetMinimumBalanceFromRpc` / `createClientWithFetchAccountsFromRpc` / `createClientWithInterfacesFromRpc`                                         | `solana_kit`                                        | pending                          |
| `@solana/kit` re-export `@solana/promises` (`isAbortError`, `getAbortablePromise`, `safeRace`)                                                                                  | `solana_kit`                                        | pending                          |
| `@solana/plugin-interfaces` `ClientWithFetchAccounts`                                                                                                                           | (TBD)                                               | pending                          |
| `@solana/rpc-api` `getTransactionsForAddress` + shared `meta.costUnits`                                                                                                         | `solana_kit_rpc_api`, `solana_kit_rpc_types`        | pending                          |
| `@solana/rpc-transformers` stop upcasting token-balance `uiAmount`/`decimals`/`accountIndex` to bigint; export `tokenBalancesConfigs`                                           | `solana_kit_rpc_transformers`                       | pending                          |
| `@solana/transaction-introspection` `decodeTransactionFromRpcResponse` accepts confirmed transactions from any RPC method                                                       | `solana_kit_transaction_introspection`              | pending                          |

### Patch Changes

| Upstream change                                                                                             | Dart package                                           | Status                              |
| ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ | ----------------------------------- |
| `@solana/codecs-data-structures` `getBitArrayEncoder` next-offset fix (`offset + size`)                     | `solana_kit_codecs_data_structures`                    | already correct in Dart — no change |
| `@solana/codecs-data-structures` `getArrayDecoder` O(1) emptiness check                                     | `solana_kit_codecs_data_structures`                    | pending (perf)                      |
| `@solana/codecs-data-structures` `getPatternMatchCodec`/`Encoder` predicate narrowing                       | `solana_kit_codecs_data_structures`                    | pending                             |
| `@solana/rpc-api` stop upcasting transaction `version` to bigint                                            | `solana_kit_rpc_transformers` / `solana_kit_rpc_types` | pending                             |
| `@solana/transaction-messages` `compressTransactionMessageUsingAddressLookupTables` rejects v1 transactions | `solana_kit_transaction_messages`                      | pending                             |
| `@solana/kit` / `@solana/plugin-core` `withCleanup` Safari `DisposableStack` fix                            | n/a (JS-runtime only)                                  | not ported                          |

### Not ported

- `@solana/react` hooks (`usePayer`, `useIdentity`, `usePlanTransaction`, `useSendTransaction`, `useAirdrop`, `useClient` type param) — React-only.

## Progress

- `solana_kit_errors`: added the three new error codes and messages
  (`5607018`, `5607019`, `8195001`). `dart analyze` clean.
- `solana_kit_subscribable`: `bridgeStoreToAsyncIterable` (Stream-based port).
- `solana_kit_offchain_messages`: `assertOffchainMessageV1Equal`.
- `solana_kit_instruction_plans`: `createTransactionPlanExecutor` callback may
  return the successful result context.
- `solana_kit_rpc_transformers`: `tokenBalancesConfigs` export.
- `solana_kit_rpc_api`: allow-list `uiTokenAmount.uiAmount`, simulate
  `accountIndex`/`decimals`, transaction `version`, and
  `getTransactionsForAddress` keypaths.
- `solana_kit_transaction_introspection`: `decodeTransactionFromRpcResponse`
  documented for any RPC method (envelope already generic).
- `solana_kit`: `ClientWithGetMinimumBalance` / `ClientWithFetchAccounts`
  interfaces + `createClientWithGetMinimumBalanceFromRpc` /
  `createClientWithFetchAccountsFromRpc` / `createClientWithInterfacesFromRpc`.
- `solana_kit_rpc_api`: `getTransactionsForAddress` request side (config,
  filters, params builder) + method registration.
- `solana_kit_rpc_types`: `meta.costUnits` on the shared transaction metadata.
- `@solana/kit` pin + `versions.json` bumped to `7.1.0`.

### Remaining (not yet ported)

- `solana_kit_rpc_types`: the `getTransactionsForAddress` response types
  (signatures/full modes).
- `solana_kit`: the `@solana/promises` re-export (`isAbortError`,
  `getAbortablePromise`, `safeRace` — needs a Dart cancellation-model
  adaptation; `AbortError` currently lives in the websocket package).

## Helius SDK (separate audit)

`solana_kit_helius` is pinned to the correct upstream `v3.0.0` commit
(`4c0c55b86eab…`, the annotated `v3.0.0` tag commit), which is the latest
upstream release. Host migration (`api-mainnet.helius-rpc.com`), webhook
toggles, and `getTransfersByAddress` are present. However the auth/payment
module lags v3.0.0: it still exposes the removed `agenticSignup` and is missing
the v3.0.0 replacements/new helpers (`signup`, `signupAndPay`, `upgradePlan`,
`payRenewal`, `payPaymentLink`, `payUSDC`, `payWithMemo`, `pollPayment`,
`purchaseCredits`, `buildTokenTransfer`, `signupHelpers`). To be addressed in a
separate PR.
