---
"solana_kit_errors": minor
"solana_kit_subscribable": minor
"solana_kit_offchain_messages": minor
"solana_kit_instruction_plans": minor
"solana_kit": minor
"solana_kit_rpc_transformers": patch
"solana_kit_rpc_api": patch
"solana_kit_rpc_types": patch
"solana_kit_transaction_introspection": patch
---

# @solana/kit v7.1.0 upstream sync

Ports the `@solana/kit` `v7.1.0` changes into the Dart SDK.

## solana_kit_errors

Adds the three new error codes introduced in `@solana/kit` v7.1.0:

- `offchainMessageContentDoesNotMatchExpected` (`5607018`) — from
  `@solana/offchain-messages`'s new `assertOffchainMessageV1Equal` helper.
- `offchainMessageRequiredSignatoriesDoNotMatchExpected` (`5607019`) — same.
- `subscribableStreamClosedWithoutError` (`8195001`) — from
  `@solana/subscribable`'s new `bridgeStoreToAsyncIterable` helper.

## solana_kit_subscribable

Adds `bridgeStoreToAsyncIterable`, which adapts a `ReactiveStreamStore` into
a pull-based `Stream` (the Dart equivalent of the upstream `AsyncIterable`).
It seeds from the store's current snapshot, yields loaded values
(latest-wins), throws on error (substituting
`subscribableStreamClosedWithoutError` when the error payload is nullish),
and ends cleanly when the `CancellationToken` fires. The caller owns the
store's lifecycle (`connect()`/`reset()`).

## solana_kit_offchain_messages

Adds `assertOffchainMessageV1Equal`, which asserts that a version 1 offchain
message received from an untrusted signer is the message you expected it to
sign. Compares content (reporting UTF-8 byte lengths) and required
signatories (order-insensitive, sorted for comparison), throwing
`offchainMessageContentDoesNotMatchExpected` /
`offchainMessageRequiredSignatoriesDoNotMatchExpected` on mismatch.

## solana_kit_instruction_plans

`createTransactionPlanExecutor`'s `executeTransactionMessage` callback may now
return the context of a successful result (a map that must include a
`signature`) instead of a `Signature` or `Transaction`. The returned context
is merged with the mutable context, taking precedence. Returning a
`Signature` or `Transaction` still behaves as before (stored as
`context['signature']` / `context['transaction']` with the signature derived).

## solana_kit_rpc_transformers / solana_kit_rpc_api

- New `tokenBalancesConfigs` export (`accountIndex`, `uiTokenAmount.decimals`,
  `uiTokenAmount.uiAmount`).
- `getTransaction`, `getBlock`, and `simulateTransaction` now allow-list
  `uiTokenAmount.uiAmount` (previously upcast to `BigInt` when whole).
- `simulateTransaction` now allow-lists token-balance `accountIndex` and
  `uiTokenAmount.decimals`.
- `getTransaction` and `getBlock` now allow-list the transaction `version`
  (previously arrived as `0n` while typechecking as `0`).
- `getTransactionsForAddress` allowed-numeric keypaths.

## solana_kit

Adds the v7.1.0 client-interface helpers:

- `ClientWithGetMinimumBalance` and `ClientWithFetchAccounts` interfaces.
- `createClientWithGetMinimumBalanceFromRpc` — computes the rent-exempt
  minimum balance via `getMinimumBalanceForRentExemption` (with the
  `withoutHeader` rate-recovery trick).
- `createClientWithFetchAccountsFromRpc` — dispatches on address count
  (`getAccountInfo` / `getMultipleAccounts` / empty short-circuit).
- `createClientWithInterfacesFromRpc` — returns both interfaces.

## solana_kit_rpc_api

Adds the `getTransactionsForAddress` RPC method request side: config
(commitment, filters, limit, minContextSlot, paginationToken, sortOrder,
encoding, maxSupportedTransactionVersion, transactionDetails), filters
(blockTime/signature/slot comparisons, status, tokenAccounts), and the params
builder. Response types (signatures/full modes) and the shared `meta.costUnits`
field are still in progress.

## Remaining (in progress)

The following v7.1.0 changes still need to be ported and will be appended to
this changeset as they land:

- `solana_kit_rpc_types`: the `getTransactionsForAddress` response types
  (signatures/full modes) and the shared `meta.costUnits` field.
- `solana_kit`: re-export `@solana/promises` (`isAbortError`,
  `getAbortablePromise`, `safeRace` — needs a Dart cancellation-model
  adaptation; `AbortError` currently lives in the websocket package).
- `@solana/plugin-interfaces` `ClientWithFetchAccounts` interface (ported as
  a Dart interface in `solana_kit`).

Already present in the Dart port (no change needed):

- `@solana/codecs-data-structures` `getBitArrayEncoder` next-offset fix
  (`offset + size`) — the Dart encoder already returns `offset + size`.
- `@solana/transaction-messages`
  `compressTransactionMessageUsingAddressLookupTables` rejecting v1
  transactions — a compile-time-only type narrowing upstream; not expressible
  in Dart's single-class `TransactionMessage` model, so no runtime change.

`@solana/react` changes are not ported (React-only).