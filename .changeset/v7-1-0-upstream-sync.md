---
"solana_kit_errors": minor
---

# @solana/kit v7.1.0 upstream sync

Ports the `@solana/kit` `v7.1.0` changes into the Dart SDK. This changeset
grows as each affected package is ported.

## solana_kit_errors

Adds the three new error codes introduced in `@solana/kit` v7.1.0:

- `offchainMessageContentDoesNotMatchExpected` (`5607018`) — from
  `@solana/offchain-messages`'s new `assertOffchainMessageV1Equal` helper.
- `offchainMessageRequiredSignatoriesDoNotMatchExpected` (`5607019`) — same.
- `subscribableStreamClosedWithoutError` (`8195001`) — from
  `@solana/subscribable`'s new `bridgeStoreToAsyncIterable` helper.

## Remaining (in progress)

The following v7.1.0 changes still need to be ported and will be appended to
this changeset as they land:

- `solana_kit_subscribable`: `bridgeStoreToAsyncIterable`.
- `solana_kit_offchain_messages`: `assertOffchainMessageV1Equal`.
- `solana_kit_instruction_plans`: `createTransactionPlanExecutor` callback may
  return the successful result context (returning a `Signature`/`Transaction`
  is deprecated).
- `solana_kit`: `createClientWithGetMinimumBalanceFromRpc`,
  `createClientWithFetchAccountsFromRpc`, `createClientWithInterfacesFromRpc`;
  re-export `@solana/promises` (`isAbortError`, `getAbortablePromise`,
  `safeRace`).
- `solana_kit_rpc_api` / `solana_kit_rpc_types`: `getTransactionsForAddress`
  RPC method and shared `meta.costUnits` field.
- `solana_kit_rpc_transformers`: stop upcasting token-balance `uiAmount`,
  `decimals`, `accountIndex`, and transaction `version` to `bigint`; export
  `tokenBalancesConfigs`.
- `solana_kit_transaction_introspection`:
  `decodeTransactionFromRpcResponse` accepts confirmed transactions from any
  RPC method (not just `getTransaction`).
- `solana_kit_transaction_messages`:
  `compressTransactionMessageUsingAddressLookupTables` rejects v1 transactions.
- `@solana/plugin-interfaces` `ClientWithFetchAccounts` interface.

Already present in the Dart port (no change needed):

- `@solana/codecs-data-structures` `getBitArrayEncoder` next-offset fix
  (`offset + size`) — the Dart encoder already returns `offset + size`.

`@solana/react` changes are not ported (React-only).
