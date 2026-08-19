# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.8.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.8.0) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_rpc_types` was updated to 0.8.0 as part of group `main`.

## [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.7.0) (2026-08-18)

### 💥 Breaking Change

#### @solana/kit v7.0.0 upstream sync (foundational breaking changes)

Ports the foundational breaking changes from `@solana/kit` v7.0.0:

- **solana_kit_errors**: new `transactionIntrospection` error domain + codes (`transactionFailedToDecompileInstructionAccountIndexOutOfRange`, `transactionIntrospectionCannotDecodeJsonParsedTransaction`, `transactionIntrospectionUnrecognizedGetTransactionResponse`) and instruction-plans max-instructions codes (`instructionPlansInvalidMaxInstructionsPerTransaction`, `instructionPlansMaxInstructionsPerTransactionExceeded`).
- **solana_kit_codecs_data_structures**: `createDependentStructDecoder` fluent builder for structs whose later fields depend on earlier decoded values.
- **solana_kit_instruction_plans**: configurable `maxInstructionsPerTransaction` (default 16, limit 64) on `TransactionPlannerConfig`, individual `TransactionPlanner` invocations, and `MessagePacker`; invocation-specific planner values take precedence without leaking to later calls.
- **solana_kit_rpc_types**: `isSolanaRpcResponse` runtime guard.
- **solana_kit**: removed the local `getMinimumBalanceForRentExemption` helper (rent exemption is becoming dynamic; use the RPC method instead).
- **solana_kit_subscribable**: `ReactiveStreamStore` v7 rewrite — caller-driven `connect()`/`reset()`/`withSignal()`, starts `idle`, collapses `retrying` into `loading` (stale-while-revalidate), renames `getUnifiedState()` → `getState()`; removed `retry()`, value-only `getState()`, `getError()`. `ReactiveActionStore` now passes a fresh `CancellationToken` to every action, cancels superseded/reset/disposed dispatches, suppresses late outcomes, exposes caller cancellation through `withSignal()`, and preserves stale results and errors while running.
- **solana_kit_transaction_introspection**: new first-class package porting `@solana/transaction-introspection` — RPC transaction decoding, instruction and inner-instruction extraction, loaded-address resolution, and instruction walking helpers; re-exported from the `solana_kit` umbrella.
- **solana_kit_rpc_parsed_types** / **solana_kit_rpc_transformers** / **solana_kit_rpc_api**: Agave 4.1.0 parsed-account types — vote commissions/latency as `int` (not `BigInt`); rent sysvar union (`lamportsPerByte` vs deprecated `burnPercent`/`exemptionThreshold`/ `lamportsPerByteYear`); stake `warmupCooldownRate` optional; config `slashPenalty`/`warmupCooldownRate` deprecated; keep vote commissions and latency as `int` in the numeric-keypath allow-lists.

Migration: `getMinimumBalanceForRentExemption(space)` → `rpc.getMinimumBalanceForRentExemption(space).send()`; `store.retry()` → `store.connect()`; `store.getUnifiedState()` → `store.getState()`; the deprecated `ReactiveStore`/`createReactiveStoreFromStreams` → `createReactiveStreamStore`; reactive actions must migrate from `(args) async => result` to `(signal, args) async => result`.

```dart
// Before
final lamports = getMinimumBalanceForRentExemption(space);
store.retry();
final state = store.getUnifiedState();

// After
final lamports = await rpc.getMinimumBalanceForRentExemption(space).send();
store.connect();
final state = store.getState();
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #204](https://github.com/openbudgetfun/solana_kit/pull/204)

### 🐛 Fixed

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

## [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.6.0) (2026-08-12)

### 💥 Breaking Change

#### Remove deprecated base58 account info types

Removes the deprecated `AccountInfoWithBase58Bytes` and `AccountInfoWithBase58EncodedData` classes. The Solana RPC API now returns account data as base64 (or base64+zstd) instead of base58. Use `AccountInfoWithBase64EncodedData` instead.

```dart
// Before
final account = AccountInfoWithBase58Bytes(data: Base58EncodedBytes('...'));

// After
final account = AccountInfoWithBase64EncodedData(
  data: (Base64EncodedBytes('...'), 'base64'),
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #196](https://github.com/openbudgetfun/solana_kit/pull/196)

#### Remove deprecated TokenAmount.uiAmount field

Removes the deprecated `uiAmount` field from `TokenAmount`. The floating-point `uiAmount` field loses precision for large token balances. Use `uiAmountString` instead, which preserves the full string representation from the RPC.

```dart
// Before
final amount = TokenAmount(
  amount: StringifiedBigInt('1000000'),
  decimals: 6,
  uiAmountString: StringifiedNumber('1'),
  uiAmount: 1.0,
);

// After
final amount = TokenAmount(
  amount: StringifiedBigInt('1000000'),
  decimals: 6,
  uiAmountString: StringifiedNumber('1'),
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #196](https://github.com/openbudgetfun/solana_kit/pull/196)

#### Remove deprecated TransactionStatus types

Removes the deprecated `TransactionStatus` sealed class and its `TransactionStatusOk` / `TransactionStatusErr` subclasses. The modern API uses a nullable `TransactionError` — `null` means success, non-null means the transaction failed with that error.

```dart
// Before
final status = TransactionStatusOk();
final error = TransactionStatusErr(TransactionErrorSimple('AccountInUse'));

// After — use nullable TransactionError directly
final error = null; // success
final error = TransactionErrorSimple('AccountInUse'); // failure
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #196](https://github.com/openbudgetfun/solana_kit/pull/196)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #188](https://github.com/openbudgetfun/solana_kit/pull/188)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.5.0) (2026-06-01)

### 💥 Breaking Change

#### Raise minimum Dart SDK to 3.12

Raise the minimum supported Dart SDK constraint to `^3.12.0` across public Dart packages.

This is a breaking change because consumers must use Dart 3.12 or newer. Flutter consumers must use a Flutter SDK that bundles Dart 3.12 or newer.

```yaml
environment:
  sdk: ^3.12.0
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`32d5d36`](https://github.com/openbudgetfun/solana_kit/commit/32d5d367abb7615fea5ee341f03d17c2bc0d66dd)

### 🧪 Testing

#### Improve test coverage to 95%+ across all packages

Added 500+ tests covering equality/hashCode/toString, codec edge cases, error paths, and constructor variants. Removed dead code in fast_stable_stringify. Fixed concurrent modification bug in subscribable.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`48216f9`](https://github.com/openbudgetfun/solana_kit/commit/48216f9af0ff058d7db83994e5bdb3b9be95fdf8) · _Last updated in:_ [`b7f5419`](https://github.com/openbudgetfun/solana_kit/commit/b7f5419bbe792d4ba1731eba227088d8f74a3ebb)

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 🚀 Feature

#### Replace string encoding fields with AccountEncoding

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Add LatestBlockhashValue and Sol type

Add LatestBlockhashValue model and full Sol fixed-point…

Add `LatestBlockhashValue` model and full `Sol` fixed-point type

**`LatestBlockhashValue`** (`lib/src/latest_blockhash_value.dart`):

A new `@immutable` value class that wraps the two fields returned by `getLatestBlockhash` — a `Blockhash` and a `BigInt lastValidBlockHeight`. This gives downstream callers a typed model instead of navigating a raw `Map` for the latest-blockhash response. The class implements structural equality (`==` / `hashCode`) and a descriptive `toString`.

**`Sol` extension type and helpers** (`lib/src/sol.dart`):

A complete fixed-point SOL representation backed by an exact Lamports `BigInt`:

- `Sol` is an `extension type` implementing both `Lamports` and `Object`, so it interops seamlessly with existing `Lamports`-accepting APIs.
- `sol(String, {RoundingMode})` parses a decimal SOL string (up to 9 fractional digits) into `Sol`. A `RoundingMode` enum (`strict`, `down`, `up`, `halfUp`) controls behaviour when the input has excess precision.
- `solToLamports` / `lamportsToSol` provide lossless round-trip conversions.
- `Sol.toDecimalString()` formats the value back to a human-readable decimal string without trailing zeros.
- `getSolEncoder()`, `getSolDecoder()`, and `getSolCodec()` produce binary codecs that read/write the underlying 64-bit little-endian Lamports count, matching the on-chain wire format.

Both types are exported from the package barrel (`solana_kit_rpc_types.dart`). The `LatestBlockhashValue` export enables `solana_kit_rpc` to use it in its new typed `getLatestBlockhashValue` method. The `Sol` type adds a long-requested ergonomic layer for displaying and parsing SOL amounts without manual BigInt arithmetic.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Replace unsafe .cast() with JsonReader

Introduce internal JsonReader helper that replaces unsafe…

Introduce internal `JsonReader` helper that replaces unsafe `.cast<T>()` list

casts and bare `as` casts in all `fromJson` factories with explicit typed accessors. Parse errors now surface at construction time via a descriptive `FormatException` that includes the field name, rather than deferring until element access. All ten type files (`das_types`, `enhanced_types`, `zk_types`, `wallet_types`, `webhook_types`, `rpc_v2_types`, `auth_types`, `staking_types`, `priority_fee_types`, `smart_transaction_types`) have been migrated. The public API is unchanged.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Replace dynamic with Object?

Replace dynamic with Object? across lib source files; remaining dynamic usage is only in test matcher API signatures required by the test package.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fe249a4`](https://github.com/openbudgetfun/solana_kit/commit/fe249a46e06edf2f4cc924b30c4c463e8ea9a910) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add equality to value types

Add == / hashCode / toString to value types across…

Add == / hashCode / toString to value types across rpc_types, rpc_api, rpc_parsed_types, rpc_spec_types, instructions, transaction_messages, and transaction_confirmation.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add account client and RPC response models

Add a higher-level Solana account client plus typed RPC…

Add a higher-level Solana account client plus typed RPC response wrappers for common account, balance, blockhash, and multi-account request flows.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`aa54336`](https://github.com/openbudgetfun/solana_kit/commit/aa54336c1e9a6c4ae5df1adafc1822cfccf342fa) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add SOL conversion helpers alongside lamports helpers

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)
