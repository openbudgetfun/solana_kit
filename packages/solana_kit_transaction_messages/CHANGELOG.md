# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.9.1](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_transaction_messages` was updated to 0.9.1 as part of group `main`.

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 💥 Breaking Change

#### Sync upstream `@solana/kit` v8.1.0

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

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #225](https://github.com/openbudgetfun/solana_kit/pull/225) · _Related issues:_ [#1899](https://github.com/openbudgetfun/solana_kit/issues/1899), [#1902](https://github.com/openbudgetfun/solana_kit/issues/1902), [#1910](https://github.com/openbudgetfun/solana_kit/issues/1910), [#1913](https://github.com/openbudgetfun/solana_kit/issues/1913), [#1948](https://github.com/openbudgetfun/solana_kit/issues/1948), [#1951](https://github.com/openbudgetfun/solana_kit/issues/1951), [#1957](https://github.com/openbudgetfun/solana_kit/issues/1957), [#1970](https://github.com/openbudgetfun/solana_kit/issues/1970), [#1971](https://github.com/openbudgetfun/solana_kit/issues/1971), [#1972](https://github.com/openbudgetfun/solana_kit/issues/1972), [#1979](https://github.com/openbudgetfun/solana_kit/issues/1979), [#220](https://github.com/openbudgetfun/solana_kit/issues/220)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## [0.8.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.8.0) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_transaction_messages` was updated to 0.8.0 as part of group `main`.

## [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.7.0) (2026-08-18)

### 📖 Documentation

#### Reformat package docs

Docs have been reformatted to remove line wrapping.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #212](https://github.com/openbudgetfun/solana_kit/pull/212)

## [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.6.0) (2026-08-12)

### 🚀 Feature

#### Upstream @solana/kit 6.10.0 parity

Updates core packages to match upstream `@solana/kit` `6.10.0`:

- **solana_kit_errors**: Adds 6 new error codes from `@solana/errors` 6.10: `JSON_RPC__SERVER_ERROR_NO_SLOT_HISTORY` (-32021), `JSON_RPC__SERVER_ERROR_FILTER_TRANSACTION_NOT_FOUND` (-32020), `TRANSACTION__FAILED_TO_ESTIMATE_LOADED_ACCOUNTS_DATA_SIZE_LIMIT` (5663036), `TRANSACTION__FAILED_WHEN_SIMULATING_TO_ESTIMATE_RESOURCE_LIMITS` (5663037), `SUBSCRIBABLE__RETRY_NOT_SUPPORTED` (8195000), `WALLET__ACCOUNT_NOT_AVAILABLE` (8900003). Adds `subscribable` and `wallet` error domains. Updates `unwrapSimulationError` to treat resource-limit simulation failures as simulation errors.

- **solana_kit_subscribable**: Adds `ReactiveActionStore<TArgs, TResult>` with idle/running/success/error states, `dispatch`/`dispatchAsync`/`reset`. Adds `ReactiveStreamStore<T>` with loading/loaded/error/retrying states, `getUnifiedState` and `retry`. Mirrors upstream `@solana/subscribable` 6.10.

- **solana_kit_rpc_spec**: Adds `PendingRpcRequest.reactiveStore()` returning a `ReactiveActionStore` for reactive request dispatch.

- **solana_kit_rpc_api**: Adds `clientId` to `ClusterNode`. Documents `tpu` and `tpuForwards` as deprecated in favor of QUIC fields.

- **solana_kit_transaction_messages**: Adds resource-limit estimation helpers: `ResourceLimitsEstimate`, `estimateResourceLimitsFactory`, `estimateAndSetResourceLimitsFactory`, `fillTransactionMessageProvisoryResourceLimits`, `getTransactionMessageLoadedAccountsDataSizeLimit`, `setTransactionMessageLoadedAccountsDataSizeLimit`.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #195](https://github.com/openbudgetfun/solana_kit/pull/195)

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

### 🐛 Fixed

#### Add well-known program, sysvar, SPL, Metaplex, and token mint address constants

Add centralized address constants to `solana_kit_addresses` so that any package can reference well-known on-chain addresses without importing the full domain package or hardcoding strings.

New exports:

- `program_addresses.dart` — All Agave/Solana native program addresses (system, ALT, BPF loaders, compute budget, config, stake, vote, etc.)
- `sysvar_addresses.dart` — All sysvar addresses (clock, rent, recentBlockhashes, fees, rewards, etc.) plus the sysvar owner address
- `spl_addresses.dart` — SPL program addresses (Token, Token-2022, ATA, Memo, Memo Legacy)
- `metaplex_addresses.dart` — Metaplex program addresses (Token Metadata, Bubblegum, Auth Rules, Core, SPL Account Compression, Noop)
- `well_known_addresses.dart` — Well-known token mint addresses (Wrapped SOL, USDC, USDT)

Also re-exports from `solana_kit_address` (Address type, codecs, comparator, PublicKey) and `solana_kit_address_constants` (well-known address constants).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3f596ef`](https://github.com/openbudgetfun/solana_kit/commit/3f596ef95c0d00714db97a4338ac9342f1fabfb7) · _Last updated in:_ [`4643648`](https://github.com/openbudgetfun/solana_kit/commit/46436481a28eab1c803175bee56e98e89fe8fac6)

### 🧪 Testing

#### Improve test coverage to 95%+ across all packages

Added 500+ tests covering equality/hashCode/toString, codec edge cases, error paths, and constructor variants. Removed dead code in fast_stable_stringify. Fixed concurrent modification bug in subscribable.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`48216f9`](https://github.com/openbudgetfun/solana_kit/commit/48216f9af0ff058d7db83994e5bdb3b9be95fdf8) · _Last updated in:_ [`b7f5419`](https://github.com/openbudgetfun/solana_kit/commit/b7f5419bbe792d4ba1731eba227088d8f74a3ebb)

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 🚀 Feature

#### Deprecate solana_kit_functional

Deprecate solana_kit_functional; the Pipe extension is now re-exported from solana_kit_transaction_messages and the umbrella package.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add == and hashCode to public value-type

Add `==` and `hashCode` to public value-type, config, and response classes.

Implements issue #114. All config, request, and response classes in the RPC layer, as well as core instruction and transaction-message value types, now support structural equality. This enables correct use in `Set`s, as `Map` keys, and in test assertions.

All affected classes are also annotated with `@immutable` to satisfy the `avoid_equals_and_hash_code_on_mutable_classes` lint rule, since every field is already `final`.

Packages that did not previously depend on `meta` now declare `meta: any` explicitly (`solana_kit_rpc_api`, `solana_kit_transaction_confirmation`, `solana_kit_rpc_spec_types`, `solana_kit_rpc_parsed_types`).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`5bccc42`](https://github.com/openbudgetfun/solana_kit/commit/5bccc42120e7bc038fc507719727500364a43bd9)

#### Add full transaction message v1 support

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)
