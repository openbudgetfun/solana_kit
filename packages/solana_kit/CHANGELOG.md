# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

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

### 🐛 Fixed

#### Kit-plugin style Surfpool client + SDK-based integration tests

##### `solana_kit_surfpool` (minor)

Add `createSurfpoolClient()` / `connectSurfpoolClient()` returning a `SurfpoolClient` wired up like the `@solana/surfpool/kit` plugin for TypeScript:

- `rpc` / `rpcSubscriptions` — Solana Kit RPC and subscriptions clients pointed at the Surfnet.
- `payer` — the Surfnet's pre-funded `KeyPairSigner` (embedded mode) or a caller-provided funded signer (attach mode).
- `cheatcodes` — a typed `SurfnetCheatcodes` RPC covering every `surfnet_*` cheatcode with the prefix stripped (`timeTravel`, `pauseClock`, `setAccount`, `writeProgram`, …).
- `rpcUrl` / `wsUrl` — the Surfnet's HTTP and WebSocket URLs.
- `airdrop` / `getMinimumBalance` — funding and rent-exemption helpers.
- `stop()` — idempotent teardown that stops the Surfnet when this client started it.

`createSurfpoolClient` stops the Surfnet if wiring fails, so no orphaned process or ports are left behind. The new API is fully unit-tested with 100% patch coverage.

##### `codama-renderers-dart` (patch)

Fix `visitSizePrefixType` so BigInt-width size prefixes (u64/u128/i64/i128) generate `transformEncoder`/`transformDecoder` wrappers instead of substituting u32. The system program's bincode String length is u64, so the u32 substitution broke on-chain encoding of seed fields.

##### `solana_kit_system` (patch)

Regenerate the system program client with the size-prefix renderer fix; `createAccountWithSeed`, `allocateWithSeed`, `assignWithSeed`, and `transferSolWithSeed` now encode their u64 String-length prefixes correctly.

##### `solana_kit_errors` (patch)

Fix `getSolanaErrorFromTransactionError` to handle `account_index` values returned as `BigInt` by some RPC nodes (e.g. SurfPool), matching the earlier instruction-error-index fix.

##### `solana_kit` (patch)

Convert `test/integration/rpc_basic_test.dart` to start its own Surfpool via the SDK instead of requiring an externally launched validator.

##### `solana_kit_mpl_bubblegum` (patch)

Convert the compressed-NFT integration test to start its own Surfpool via the SDK; add `solana_kit_surfpool` as a dev dependency.

##### `solana_kit_integration_tests` (minor)

Integration tests now start their own Surfpool per test file via the SDK (auto-allocated ports, parallel-safe) instead of requiring an externally launched instance. Adds the gap-coverage tests: loader full deploy, system seed-based instructions, config store (committed `config-v3.0.0.so` artifact), subscriptions on-chain lifecycle, ALT extend/deactivate/close, error paths, token/2022 transfer+burn+setAuthority+closeAccount, stake authorize, and ATA idempotency.

```dart
// Before: manual Surfnet wiring
final surfnet = await Surfnet.start();
final rpc = createSolanaRpc(surfnet.rpcUrl);

// After: kit-plugin style client
final client = await createSurfpoolClient();
final rpc = client.rpc;
final payer = client.payer;
await client.cheatcodes.timeTravel(...);
await client.stop();
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #208](https://github.com/openbudgetfun/solana_kit/pull/208)

## [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.6.0) (2026-08-12)

### 💥 Breaking Change

#### Remove deprecated APIs across the SDK

**Breaking change.** Clears every `remove_deprecations_in_breaking_versions` lint warning by deleting deprecated members and migrating call sites to their documented replacements. No deprecations are suppressed; each deprecated declaration is removed.

##### `createEmptyClient` (solana_kit)

Removed the deprecated `createEmptyClient` alias. Use `createClient` instead.

```dart
// Before
final client = createEmptyClient({'ready': true});
// After
final client = createClient({'ready': true});
```

##### Deprecated fixed-point rounding modes (solana_kit_fixed_points)

Removed the deprecated `FixedPointRoundingMode` values `down`, `up`, and `halfUp`. The surviving modes are `strict`, `floor`, `ceil`, `trunc`, `round`.

- `down` was a duplicate of `trunc` — use `FixedPointRoundingMode.trunc`.
- `halfUp` was a duplicate of `round` — use `FixedPointRoundingMode.round`.
- `up` ("round away from zero") has no single replacement. Use `floor` or `ceil` depending on the sign of the value, or `round` for nearest.

##### Deprecated `Pipe` extension (solana_kit_functional)

Removed the deprecated `Pipe` extension from `solana_kit_functional`. `Pipe` is re-exported from `solana_kit_transaction_messages` and the `solana_kit` umbrella. Switch imports accordingly:

```dart
// Before
import 'package:solana_kit_functional/solana_kit_functional.dart';
// After
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
```

`solana_kit` no longer depends on `solana_kit_functional`. The `solana_kit_functional` package is now an empty placeholder pending full retirement.

##### Deprecated subscriptions compatibility APIs

The deprecated `AbortSignal`/`AbortController` and `DataPublisher`/`WritableDataPublisher`/`createDataPublisher` compatibility APIs were the core transport substrate of the subscriptions stack, not a thin compatibility layer. They are replaced by stream-native and cancellation-token equivalents.

###### Cancellation

- `AbortSignal` → `CancellationToken` (from `solana_kit_subscribable`)
- `AbortController` → `CancellationTokenSource` (from `solana_kit_subscribable`)
- `controller.signal` → `source.token`
- `controller.abort([reason])` → `source.cancel([reason])`
- `signal.isAborted` → `token.isCancelled`
- `signal.reason` → `token.reason`
- `signal.future` → `token.future`

Public field/parameter names that held an `AbortSignal` (e.g. `abortSignal`, `signal`) are kept; only their type changed to `CancellationToken`. `CancellationToken` and `CancellationTokenSource` are re-exported from `solana_kit_rpc_subscriptions` and `solana_kit_rpc_subscriptions_channel_websocket` so consumers do not need a direct `solana_kit_subscribable` dependency.

`AbortError`, `isAbortError`, `getAbortableFuture`, and `normalClosureCode` remain in `solana_kit_rpc_subscriptions_channel_websocket` (behavior unchanged; their `AbortSignal?` params are now `CancellationToken?`).

###### DataPublisher → NotificationStreams

- The transport contract changed from `Future<DataPublisher>` to `Future<NotificationStreams>`.
- `RpcSubscriptionsChannel` now exposes `NotificationStreams get streams` instead of the `on(channelName, subscriber)` method.
- `createDataPublisher()`, `WritableDataPublisher`, `DataPublisher`, and the `DataPublisherStreams` extension are removed.
- The `*FromDataPublisher` helpers are removed: `createStreamFromDataPublisher`, `StreamFromDataPublisherConfig`, `createAsyncIterableFromDataPublisher`, `demultiplexDataPublisher`, `createReactiveStoreFromDataPublisher`, `createReactiveStreamStoreFromDataPublisher`.
- The stream-native helpers are kept: `ChannelStreamController`, `createStreamFromDataAndErrorStreams`, `demultiplexStream`, `createReactiveStoreFromStreams`, `ReactiveStore`, `ReactiveStreamStore`, `createReactiveStreamStore`.

###### Public subscription APIs

`PendingRpcSubscriptionsRequest.subscribe()` and `.reactive()` still return `Future<Stream<T>>` and `Future<ReactiveStore<T>>` respectively. Internally they now consume `NotificationStreams.notifications` / `.errors` instead of `DataPublisher` channels.

###### Migration

```dart
// Before
final controller = AbortController();
final stream = await pending.subscribe(
  RpcSubscribeOptions(abortSignal: controller.signal),
);
controller.abort();

// After
final source = CancellationTokenSource();
final stream = await pending.subscribe(
  RpcSubscribeOptions(abortSignal: source.token),
);
source.cancel();
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3901c24`](https://github.com/openbudgetfun/solana_kit/commit/3901c24a64bf94f8772611f62bd8d289f10fdbb8) · _Last updated in:_ [`7d98d00`](https://github.com/openbudgetfun/solana_kit/commit/7d98d00f839d36b0969791865e687bd411c46f12)

### 🐛 Fixed

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

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 🚀 Feature

#### Trim program exports from umbrella

Remove program-specific package exports from the…

Remove program-specific package exports from the `solana_kit` umbrella package so program clients remain explicit imports.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`8285b34`](https://github.com/openbudgetfun/solana_kit/commit/8285b34dc7b78f04693fc0558b6854a776ad03a2) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add integration tests CI job

Add SurfPool integration test CI job and devenv command for running integration tests.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`7983fb5`](https://github.com/openbudgetfun/solana_kit/commit/7983fb5835a8fc4093fab46317f162da76fc47cc) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add per-package codecov flags

Add Codecov patch coverage and package-level coverage…

Add Codecov patch coverage and package-level coverage flags for Dart and renderer packages.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`30e1d19`](https://github.com/openbudgetfun/solana_kit/commit/30e1d192192800481fbdc6afa57dc1a1fd255986) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Fix duplicate ecosystems.dart section in monochange.toml

Merge duplicate `[ecosystem.dart]` and `[ecosystems.dart]` TOML sections into a single `[ecosystems.dart]` section.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`d5765af`](https://github.com/openbudgetfun/solana_kit/commit/d5765af199ad10b93ff613abe46a942b70205ba1)

#### Deploy docs from main pushes

Deploy the docs site from main pushes instead of…

Deploy the docs site from `main` pushes instead of release-tag events so GitHub Pages deployments comply with the repository's `github-pages` environment branch policy.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`8543d72`](https://github.com/openbudgetfun/solana_kit/commit/8543d72c37cef9f94189c4be9209d57863ebcf88) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add shared test fixtures and coverage gates

Add shared workspace test fixtures plus risk-tier package…

Add shared workspace test fixtures plus risk-tier package coverage gates so high-risk Solana Kit packages stay above 90% line coverage in CI.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ba96efb`](https://github.com/openbudgetfun/solana_kit/commit/ba96efba2e88ada3944ab2a9b0694d18d315a89d) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Expand MDT doc callouts

Expand MDT-backed documentation callouts for preferred…

Expand MDT-backed documentation callouts for preferred Dart paths, compatibility notes, parity status, security guidance, and Android-only Mobile Wallet Adapter platform messaging across the workspace docs and package surfaces.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`53acc17`](https://github.com/openbudgetfun/solana_kit/commit/53acc174471dc42d8f0c6ce92ca9f636754401e9) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Replace dynamic with Object?

Replace dynamic with Object? across lib source files; remaining dynamic usage is only in test matcher API signatures required by the test package.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fe249a4`](https://github.com/openbudgetfun/solana_kit/commit/fe249a46e06edf2f4cc924b30c4c463e8ea9a910) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add barrel-file re-export tests

Add barrel-file re-export tests for solana_kit and solana_kit_codecs umbrella packages.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Expand coverage thresholds to 26 packages

Expand per-package coverage thresholds from 5 packages to…

Expand per-package coverage thresholds from 5 packages to 26 packages; core packages at 80%+, high-risk at 60%+.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fe249a4`](https://github.com/openbudgetfun/solana_kit/commit/fe249a46e06edf2f4cc924b30c4c463e8ea9a910) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add SurfPool integration test directory

Add integration test directory with basic RPC tests…

Add integration test directory with basic RPC tests designed for SurfPool local validator; not run in CI automatically.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fe249a4`](https://github.com/openbudgetfun/solana_kit/commit/fe249a46e06edf2f4cc924b30c4c463e8ea9a910) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Enable public_member_api_docs lint

Enable public_member_api_docs lint rule with file-level suppressions for incremental backfill.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add examples/ directory with 26 scripts

Add a top-level examples/ directory with 26 standalone…

Add a top-level `examples/` directory with 26 standalone Dart example scripts and a README covering addresses, keys, codecs, structs, options, errors, sysvars, offchain messages, transaction building/signing/confirmation, RPC, subscriptions, accounts, Helius DAS/priority-fees, functional pipe, fast-stable-stringify, address comparator, union codecs, and transaction serialisation.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add solana-program reference repos

Add solana-program/ reference repos to clone:repos with…

Add solana-program/* reference repos to clone:repos with pinned version tracking for all 11 program repos.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`0d394fb`](https://github.com/openbudgetfun/solana_kit/commit/0d394fba231feb79137da5f74a015180a2c13c99) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add transaction execution boundary

Add a higher-level transaction execution boundary that…

Add a higher-level transaction execution boundary that combines instruction-plan planning, signing, and sending into a single structured outcome, with a signer-based convenience wrapper for common app flows.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`69db7ef`](https://github.com/openbudgetfun/solana_kit/commit/69db7ef8dce81e51e5980c4254a382c76082617c) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add account client and RPC response models

Add a higher-level Solana account client plus typed RPC…

Add a higher-level Solana account client plus typed RPC response wrappers for common account, balance, blockhash, and multi-account request flows.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`aa54336`](https://github.com/openbudgetfun/solana_kit/commit/aa54336c1e9a6c4ae5df1adafc1822cfccf342fa) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add upstream parity test harness

Add an executable upstream parity harness that compares…

Add an executable upstream parity harness that compares selected Solana Kit Dart behaviors against the tracked `@solana/kit` release in CI and local development.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bf0f168`](https://github.com/openbudgetfun/solana_kit/commit/bf0f168606f039e9029a4f5c25942e591ef9940d) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Expose upstream-compatible client helpers

Expose the new upstream-compatible convenience surface…

Expose the new upstream-compatible convenience surface from the umbrella package. This re-exports the fixed-point helpers, functional helpers, compute-unit estimation helpers, Dart-native client/plugin composition APIs, identity and payer capability interfaces, and slot-tracking stream/reactive-store helpers used to combine an initial RPC value with live subscription updates.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Fix MDT product callout rendering so preferred-path

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a7355ff`](https://github.com/openbudgetfun/solana_kit/commit/a7355ffb6f9227fcf9462cdc1d13608fa3d5242b) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Move reference repos to config JSON

Move reference repo pins out of devenv.nix into…

Move reference repo pins out of `devenv.nix` into `config/reference-repos.json`, and teach `clone:repos` to read that config and report repo status.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`731da8d`](https://github.com/openbudgetfun/solana_kit/commit/731da8da45af0a34e66ad9347f19dbcd6b461485) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
