# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_offchain_messages [0.3.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_offchain_messages/v0.3.2) (2026-05-30)

### 🚀 Feature

#### Detached from main group

This package is now released independently rather than as part of the main solana_kit group. Off-chain message signing is a standalone capability that does not depend on the core solana_kit release cycle, so an independent release track is more appropriate.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

## solana_kit_offchain_messages [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_offchain_messages/v0.4.0) (2026-06-01)

### 💥 Breaking Change

#### Raise minimum Dart SDK to 3.12

Raise the minimum supported Dart SDK constraint to `^3.12.0` across public Dart packages.

This is a breaking change because consumers must use Dart 3.12 or newer. Flutter consumers must use a Flutter SDK that bundles Dart 3.12 or newer.

```yaml
environment:
  sdk: ^3.12.0
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`32d5d36`](https://github.com/openbudgetfun/solana_kit/commit/32d5d367abb7615fea5ee341f03d17c2bc0d66dd)

## solana_kit_offchain_messages [0.4.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_offchain_messages/v0.4.1) (2026-08-12)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #188](https://github.com/openbudgetfun/solana_kit/pull/188)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## solana_kit_offchain_messages [0.4.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_offchain_messages/v0.4.2) (2026-08-18)

### 🚀 Feature

#### @solana/kit v7.1.0 upstream sync

Ports the `@solana/kit` `v7.1.0` changes into the Dart SDK.

##### solana_kit_errors

Adds the three new error codes introduced in `@solana/kit` v7.1.0:

- `offchainMessageContentDoesNotMatchExpected` (`5607018`) — from `@solana/offchain-messages`'s new `assertOffchainMessageV1Equal` helper.
- `offchainMessageRequiredSignatoriesDoNotMatchExpected` (`5607019`) — same.
- `subscribableStreamClosedWithoutError` (`8195001`) — from `@solana/subscribable`'s new `bridgeStoreToAsyncIterable` helper.

##### solana_kit_subscribable

Adds `bridgeStoreToAsyncIterable`, which adapts a `ReactiveStreamStore` into a pull-based `Stream` (the Dart equivalent of the upstream `AsyncIterable`). It seeds from the store's current snapshot, yields loaded values (latest-wins), throws on error (substituting `subscribableStreamClosedWithoutError` when the error payload is nullish), and ends cleanly when the `CancellationToken` fires. The caller owns the store's lifecycle (`connect()`/`reset()`).

##### solana_kit_offchain_messages

Adds `assertOffchainMessageV1Equal`, which asserts that a version 1 offchain message received from an untrusted signer is the message you expected it to sign. Compares content (reporting UTF-8 byte lengths) and required signatories (order-insensitive, sorted for comparison), throwing `offchainMessageContentDoesNotMatchExpected` / `offchainMessageRequiredSignatoriesDoNotMatchExpected` on mismatch.

##### solana_kit_instruction_plans

`createTransactionPlanExecutor`'s `executeTransactionMessage` callback may now return the context of a successful result (a map that must include a `signature`) instead of a `Signature` or `Transaction`. The returned context is merged with the mutable context, taking precedence. Returning a `Signature` or `Transaction` still behaves as before (stored as `context['signature']` / `context['transaction']` with the signature derived).

##### solana_kit_rpc_transformers / solana_kit_rpc_api

- New `tokenBalancesConfigs` export (`accountIndex`, `uiTokenAmount.decimals`, `uiTokenAmount.uiAmount`).
- `getTransaction`, `getBlock`, and `simulateTransaction` now allow-list `uiTokenAmount.uiAmount` (previously upcast to `BigInt` when whole).
- `simulateTransaction` now allow-lists token-balance `accountIndex` and `uiTokenAmount.decimals`.
- `getTransaction` and `getBlock` now allow-list the transaction `version` (previously arrived as `0n` while typechecking as `0`).
- `getTransactionsForAddress` allowed-numeric keypaths.

##### solana_kit

Adds the v7.1.0 client-interface helpers:

- `ClientWithGetMinimumBalance` and `ClientWithFetchAccounts` interfaces.
- `createClientWithGetMinimumBalanceFromRpc` — computes the rent-exempt minimum balance via `getMinimumBalanceForRentExemption` (with the `withoutHeader` rate-recovery trick).
- `createClientWithFetchAccountsFromRpc` — dispatches on address count (`getAccountInfo` / `getMultipleAccounts` / empty short-circuit).
- `createClientWithInterfacesFromRpc` — returns both interfaces.

Also re-exports the `@solana/promises` helpers as Dart counterparts: `isAbortError`, `getAbortablePromise`, and `safeRace` (adapted to Dart's cancellation model via `CancellationToken`; `AbortError` lives in `solana_kit_subscribable`).

##### solana_kit_rpc_api

Adds the `getTransactionsForAddress` RPC method request side: config (commitment, filters, limit, minContextSlot, paginationToken, sortOrder, encoding, maxSupportedTransactionVersion, transactionDetails), filters (blockTime/signature/slot comparisons, status, tokenAccounts), and the params builder.

##### solana_kit_rpc_types

- Adds the `getTransactionsForAddress` response types: `signatures` and `full` modes (with per-entry base fields, transaction/status variants, and the `TransactionDetails` enum).
- Adds the shared `meta.costUnits` field to the transaction meta types.

Already present in the Dart port (no change needed):

- `@solana/codecs-data-structures` `getBitArrayEncoder` next-offset fix (`offset + size`) — the Dart encoder already returns `offset + size`.
- `@solana/transaction-messages` `compressTransactionMessageUsingAddressLookupTables` rejecting v1 transactions — a compile-time-only type narrowing upstream; not expressible in Dart's single-class `TransactionMessage` model, so no runtime change.

`@solana/react` changes are not ported (React-only).

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #206](https://github.com/openbudgetfun/solana_kit/pull/206)
