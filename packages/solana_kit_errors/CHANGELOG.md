# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 🚀 Feature

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

### 🐛 Fixed

#### Reject non-canonical boolean decoder values

Boolean codecs now reject values other than zero and one with a typed error, including nullable prefixes that use boolean tags.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #217](https://github.com/openbudgetfun/solana_kit/pull/217)

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

#### On-chain integration tests for program clients + sendTransaction encoding fix

##### `solana_kit_transaction_confirmation` (patch)

Fix `sendAndConfirmTransaction` so the `sendTransaction` RPC call declares `encoding: base64`. The helper encodes the transaction as base64 via `getBase64EncodedWireTransaction` but previously left the `encoding` field unset, so real RPC nodes (including SurfPool) defaulted to base58 and rejected the payload with `invalid base58 encoding`. This path had only been exercised against a mocked transport, so the bug was latent.

##### `solana_kit_errors` (patch)

Fix `getSolanaErrorFromTransactionError` to handle instruction-error indices returned as `BigInt` (as SurfPool does). The instruction index was cast `as num`, which threw `_BigIntImpl is not a subtype of num` and masked the real on-chain instruction error. It now converts `BigInt` indices to `int`.

##### `solana_kit_address_constants` / `solana_kit_spl_account_compression` (patch)

Fix the SPL Account Compression, Noop, and MPL Bubblegum program addresses to the live mainnet IDs:

- `splAccountCompressionProgramAddress`: `cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi` -> `cmtDvXumGCrqC1Age74AVPhSRVXJMd8PJS91L8KbNCK`
- `noopProgramAddress`: `noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK` -> `noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV`
- `mplBubblegumProgramAddress`: `BGUMAp9Gph7G9Jn2tU58R5L2qPG1Mj9HP7G3G7VYV2Ma` -> `BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY`
- `stakeConfigAddress`: `StakeConfig1111111111111111111111111111` (truncated, invalid length) -> `StakeConfig11111111111111111111111111111111`

The previous values point to accounts that do not exist on mainnet. An audit of every constant in the package against mainnet confirmed all other addresses are correct (native/runtime programs and sysvars are canonical per `solana-sdk-ids`; some native programs and lazily-created sysvars legitimately have no materialized account). SurfPool integration tests for MPL Bubblegum confirmed the corrected IDs resolve to deployed programs.

##### `solana_kit_integration_tests` (new, internal)

A non-published workspace package that runs every generated program client end-to-end against a local SurfPool Surfnet. It ships a shared `IntegrationTestEnv` harness (connects-or-starts SurfPool, funds a payer, builds/signs/sends/confirms transactions, deploys programs) and on-chain suites that assert the real on-chain outcome of each instruction:

- Builtin programs: Memo, System (transfer), Compute Budget, Token (createMint -> mintTo), Token-2022, Associated Token Account, Address Lookup Table, Stake (initialize), and BPF Loader (initializeBuffer).
- Subscriptions: the compiled program (`.so`) is committed under `config/programs/` and deployed on-chain; `initSubscriptionAuthority` runs and its PDA is verified on-chain.
- MPL Bubblegum: Bubblegum + SPL Account Compression + Noop are deployed on-chain (verified executable + owned by the BPF loader) and the full compressed-NFT lifecycle runs end-to-end: `createTree` (with the merkle-tree account sized per the account-compression layout formulas, 31800 bytes for (maxDepth=14, maxBufferSize=64, canopyDepth=0)) -> `mintV1` -> `transfer` (leaf owner signs) -> `burn` (new owner signs). The tree state (root, proof, index) is parsed from the on-chain ConcurrentMerkleTree account and the data/creator hashes are recomputed client-side to drive transfer and burn.

The compiled `.so` artifacts are committed (not rebuilt per run) and pinned to `config/reference-repos.json`; see `config/programs/README.md` for how they are built and when they must be regenerated. Artifact names follow `<package-name-minus-solana_kit>-<program-version>.so` (e.g. `subscriptions-v0.5.0.so`, `mpl_bubblegum-v0.12.0.so`, `spl_account_compression-v0.3.3.so`, `noop-v0.2.0.so`). All four are compiled from the pinned source with `cargo build-sbf` (agave 4.2.0 / platform-tools v1.54) via `scripts/build_program_artifacts.mjs` (devenv task `build:program-artifacts`), which also applies the ahash 0.7.6 `stdsimd` patch needed by the solana-program 1.18.x programs and verifies the baked-in program IDs.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #205](https://github.com/openbudgetfun/solana_kit/pull/205)

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

### 🧪 Testing

#### Improve test coverage to 95%+ across all packages

Added 500+ tests covering equality/hashCode/toString, codec edge cases, error paths, and constructor variants. Removed dead code in fast_stable_stringify. Fixed concurrent modification bug in subscribable.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`48216f9`](https://github.com/openbudgetfun/solana_kit/commit/48216f9af0ff058d7db83994e5bdb3b9be95fdf8) · _Last updated in:_ [`b7f5419`](https://github.com/openbudgetfun/solana_kit/commit/b7f5419bbe792d4ba1731eba227088d8f74a3ebb)

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 🚀 Feature

#### Convert SolanaErrorCode to Dart enum

Convert SolanaErrorCode from a static-int abstract class…

Convert SolanaErrorCode from a static-int abstract class to a Dart enum with a numeric value field, enabling exhaustive switches, type safety, and cleaner API usage.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add upstream 6.9 Solana error codes

Add upstream 6.9 Solana error codes and messages for transaction account/instruction limit failures, invalid v1 config masks and config value kinds, filesystem write failures, and JSON-RPC errors with BigInt-compatible codes.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add downstream error codes

Add Solana error codes and messages for downstream…

Add Solana error codes and messages for downstream package features: fixed-point arithmetic (`fixedPoints*`), wallet connectivity (`wallet*`), UTF-8 null-character validation (`codecsStringContainsNullCharacters`), and key-pair grinding/filesystem helpers (`keysInvalidBase58InGrindRegex`, `keysWriteKeyPairUnsupportedEnvironment`).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Document upstream error-code typo

Document the upstream error-code typo for…

Document the upstream error-code typo for accountsOneOrMoreAccountsNotFound (32300001) in codes.dart.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add standardized error construction helpers

Add shared Solana error construction helpers and context…

Add shared Solana error construction helpers and context key conventions, then migrate representative account, RPC, and Helius call sites to preserve structured cause metadata more consistently.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`63778e5`](https://github.com/openbudgetfun/solana_kit/commit/63778e5865705ebf4370427a35466d2d3b2c75b4) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
