# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_associated_token_account [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_associated_token_account/v0.4.0) (2026-05-30)

### 💥 Breaking Change

#### New package available

Associated Token Account instruction builders and PDA helpers for the Solana Kit Dart SDK. Provides utilities for deriving associated token account addresses and constructing ATA-related instructions.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🚀 Feature

#### Add associated token account package

Add a handwritten solana_kit_associated_token_account…

Add a handwritten `solana_kit_associated_token_account` package and switch `solana_kit_token` / `solana_kit_token_2022` to share its ATA PDA helpers and instruction builders.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`0e6a808`](https://github.com/openbudgetfun/solana_kit/commit/0e6a808224c80df6cfb0c04f84a2debe5433c26b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

## solana_kit_associated_token_account [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_associated_token_account/v0.5.0) (2026-06-01)

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

## solana_kit_associated_token_account [0.5.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_associated_token_account/v0.5.1) (2026-08-12)

### 📖 Documentation

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

### 🔖 None

#### Format workflow lint follow-up files

Apply formatting-only changes discovered while adding the GitHub Actions workflow lint gate.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #185](https://github.com/openbudgetfun/solana_kit/pull/185)

## solana_kit_associated_token_account [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_associated_token_account/v0.6.0) (2026-08-18)

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

## solana_kit_associated_token_account [0.6.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_associated_token_account/v0.6.1) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_associated_token_account` was updated to 0.6.1.

## solana_kit_associated_token_account [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_associated_token_account/v0.7.0) (2026-08-30)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## solana_kit_associated_token_account [0.7.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_associated_token_account/v0.7.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_associated_token_account` was updated to 0.7.1.

## solana_kit_associated_token_account [0.7.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_associated_token_account/v0.7.2) (2026-09-06)

### Changed

- No package-specific changes were recorded; `solana_kit_associated_token_account` was updated to 0.7.2.
