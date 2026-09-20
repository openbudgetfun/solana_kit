# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_helius [0.3.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.3.2) (2026-05-30)

### 🚀 Feature

#### Detached from main group

This package is now released independently rather than as part of the main solana_kit group. The Helius SDK integration is a standalone provider package that does not depend on the core solana_kit release cycle, so an independent release track is more appropriate.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add Helius JsonReader and error context

Introduce internal JsonReader helper and structured error…

Introduce internal `JsonReader` helper and structured error context for Helius type deserialization.

##### JsonReader

Add a `JsonReader` class in `lib/src/internal/json_reader.dart` that wraps a raw `Map<String, Object?>` and provides typed accessor methods (`requireString`, `requireInt`, `optString`, `optEnum`, `requireDecodedList`, etc.). This eliminates manual `! as T` casts scattered across every `fromJson` factory in the Helius type system.

All type files (`auth_types.dart`, `das_types.dart`, `enhanced_types.dart`, `priority_fee_types.dart`, `rpc_v2_types.dart`, `smart_transaction_types.dart`, `staking_types.dart`, `wallet_types.dart`, `webhook_types.dart`, `zk_types.dart`) are migrated to use `JsonReader`, making deserialization more readable and ensuring consistent `FormatException` messages when a required field is absent or null.

##### Structured error context

`JsonRpcClient` and `RestClient` now throw errors via `createSolanaError` with structured context keys (`methodName`, `operation`, `statusCode`, `url`) instead of plain `SolanaError` constructors. This gives downstream consumers machine-readable error metadata for logging and diagnostics.

##### Impact

No public API changes. All `JsonReader` usage is internal to `lib/src/`. Deserialization behavior is functionally equivalent but error messages are now consistent `FormatException` instances rather than raw `TypeError`/`CastError` from Dart's `as` operator.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add Helius shared transport contract tests

_Owner:_ Ifiok Jr. · _Introduced in:_ [`dfcfa4c`](https://github.com/openbudgetfun/solana_kit/commit/dfcfa4c5b770f86ca6f4159a1c128e004e150a93) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Harden Helius WebSocket handling

Harden Helius WebSocket handling with secure-by-default URL validation, better subscription error propagation, and correct unsubscribe method routing.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a004fbf`](https://github.com/openbudgetfun/solana_kit/commit/a004fbf221bd3f90a9f324ab0d2c544529dbddf5) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Redact API keys in Helius config output

SEC-01: Redact API keys in `HeliusConfig.toString()` output to prevent accidental exposure in logs, error messages, or debug output.

- Added `SensitiveString` wrapper class that redacts its value in `toString()` output
- `HeliusConfig` now wraps the API key in `SensitiveString` internally
- `HeliusConfig.toString()` now shows redacted key (e.g., `****123`) instead of the full key
- `HeliusConfig.apiKey` still returns the raw key for legitimate API calls
- Removed `const` from `HeliusConfig` constructor (breaking change for `const` usage)

_Owner:_ Ifiok Jr. · _Introduced in:_ [`21ae653`](https://github.com/openbudgetfun/solana_kit/commit/21ae6537efe0f3520c1aac32eac4e088fc23aaf1) · _Last updated in:_ [`12316d5`](https://github.com/openbudgetfun/solana_kit/commit/12316d50aadfeefc7563665fbad750e37cba1fd5)

#### Constant-time comparison for sensitive strings

SEC-03: Use constant-time comparison for SensitiveString equality to prevent timing side-channel attacks.

- SensitiveString.operator== now uses constant-time byte comparison
- Prevents attackers from learning how many characters match between two secrets
- Added test verifying no early exit on mismatch

_Owner:_ Ifiok Jr. · _Introduced in:_ [`76f2c14`](https://github.com/openbudgetfun/solana_kit/commit/76f2c1456cc408da94ab54da5f68a92e4f42e965) · _Last updated in:_ [`12316d5`](https://github.com/openbudgetfun/solana_kit/commit/12316d50aadfeefc7563665fbad750e37cba1fd5)

## solana_kit_helius [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.4.0) (2026-06-01)

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

#### Align Helius v3 defaults

Update the mainnet REST host to match upstream Helius v3.0.0, add Admin project usage, webhook toggle, and `getTransfersByAddress` parity, refresh package metadata, and document the exact upstream commit used for the v3 audit.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ee30ae0`](https://github.com/openbudgetfun/solana_kit/commit/ee30ae03357be744bc81669041f0319149844af6)

## solana_kit_helius [0.4.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.4.1) (2026-06-03)

### 🐛 Fixed

#### Harden security audit findings

Disable placeholder Helius auth signing, redact Helius API keys from JSON-RPC error context, validate malformed encrypted mobile-wallet messages before slicing, and reject negative mobile-wallet sequence numbers.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #181](https://github.com/openbudgetfun/solana_kit/pull/181)

#### Add Helius transaction parity helpers

Add helpers for sender regions, sendViaSender, and createTxMessage. Expand sender and broadcast coverage.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #183](https://github.com/openbudgetfun/solana_kit/pull/183)

#### Add Helius auth signing helpers

Implement upstream-compatible Helius auth message signing with Ed25519 signatures. Also add request factories for secret key bytes and key pairs.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #183](https://github.com/openbudgetfun/solana_kit/pull/183)

## solana_kit_helius [0.4.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.4.2) (2026-08-12)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #188](https://github.com/openbudgetfun/solana_kit/pull/188)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## solana_kit_helius [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.5.0) (2026-08-18)

### 💥 Breaking Change

#### Helius SDK v3.0.0 auth/payment port

Port Helius SDK v3.0.0 auth/payment API surface

- **Added** `signup()` — unified Phase 1 signup replacing the legacy `agenticSignup`. Supports both secret-key-authenticated and pre-authenticated flows. Returns discriminated `SignupResult` (`already_subscribed`, `upgrade_required`, or `payment_required`).
- **Added** `SignupRequest` type with `secretKey()` and `preauthenticated()` constructors, replacing `AgenticSignupRequest`/`AgenticSignupResponse`.
- **Added** `SignupResult` sealed class with `AlreadySubscribedResult`, `UpgradeRequiredResult`, and `PaymentRequiredResult` variants.
- **Added** `SignupEndpoints` type for mainnet/devnet RPC URLs.
- **Added** `constants.dart` — v3.0.0 constants: `paymentHost`, `treasury`, `usdcMint`, `memoProgramId`, polling timeouts, `agentPlanId`, etc.
- **Added** `signup_helpers.dart` — `buildEndpoints()` helper.
- **Verified** existing checkout functions (`createPayment`, `getPaymentStatus`, `pollCheckoutCompletion`) match upstream v3.0.0 semantics.
- **Verified** `getAddress`, `loadKeypair`, `getHttpStatus` match upstream v3.0.0.
- **Removed** legacy `agenticSignup` method and `agentic_signup.dart` (upstream v3.0.0 removed it; `signup` is the replacement).

```dart
// Before
final result = await auth.agenticSignup(secretKey: keypair);

// After
final result = await auth.signup(
  SignupRequest.secretKey(secretKey: keypair, plan: 'agent'),
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #207](https://github.com/openbudgetfun/solana_kit/pull/207)

### 🐛 Fixed

#### Harden credentials, keys, transports, and untrusted RPC decoding

Align Helius signup and project provisioning with the v3 bearer-JWT API, generate valid Ed25519 authentication keypairs, validate payment inputs, and redact WebSocket credentials.

Dispose or clear SDK-owned key material deterministically, create key files exclusively with safe POSIX permissions, and preserve caller ownership of Surfpool signers.

Reject malformed RPC transaction and inner-instruction data instead of silently dropping it, expand private WebSocket literal filtering, and update JavaScript dependency overrides to releases without the audited advisories. Make the standalone Codama renderer workspace declare its own build tools and explicitly allow only esbuild's required install script.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #213](https://github.com/openbudgetfun/solana_kit/pull/213) · _Related issues:_ [#159](https://github.com/openbudgetfun/solana_kit/issues/159), [#163](https://github.com/openbudgetfun/solana_kit/issues/163), [#186](https://github.com/openbudgetfun/solana_kit/issues/186), [#198](https://github.com/openbudgetfun/solana_kit/issues/198), [#203](https://github.com/openbudgetfun/solana_kit/issues/203), [#204](https://github.com/openbudgetfun/solana_kit/issues/204), [#205](https://github.com/openbudgetfun/solana_kit/issues/205), [#206](https://github.com/openbudgetfun/solana_kit/issues/206), [#207](https://github.com/openbudgetfun/solana_kit/issues/207), [#208](https://github.com/openbudgetfun/solana_kit/issues/208), [#210](https://github.com/openbudgetfun/solana_kit/issues/210), [#211](https://github.com/openbudgetfun/solana_kit/issues/211), [#34](https://github.com/openbudgetfun/solana_kit/issues/34), [#37](https://github.com/openbudgetfun/solana_kit/issues/37)

### 📖 Documentation

#### Reformat package docs

Docs have been reformatted to remove line wrapping.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #212](https://github.com/openbudgetfun/solana_kit/pull/212)

## solana_kit_helius [0.5.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.5.1) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_helius` was updated to 0.5.1.

## solana_kit_helius [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.6.0) (2026-08-30)

### 🚀 Feature

#### Sync upstream `helius-sdk` v3.1.0

Tracks upstream Helius SDK APIs and behavior through `v3.1.0`:

- Adds `getBalanceAt` / `walletGetBalanceAt` for querying a wallet's balance of a token (or native SOL) at a point in the past — by Unix `time`, `datetime` string, or exact `slot` — with `balance`/`balanceRaw` returned as strings to preserve precision. `asOf` is `null` when the wallet had no matching transaction, meaning the balance is genuinely zero (upstream #334).
- Adds transaction-v1 validation: `validateTransactionV1Message` asserts the message holds no address lookups, since version 1 transactions cannot use address lookup tables (SIMD-0385), and `createTransactionMessage` refuses to build a v1 message with lookups. Adds `v1TransactionSizeLimit` (4096 bytes). `resolvePriorityFee` normalises a `lamportsCap` floor/ceiling into a whole number of lamports (upstream #341).
- Adds `sendBundleWithSender` for submitting up to 5-transaction bundles to Sender Max via `sendBundle`, tracking landing per transaction signature. Sender pricing constants now match upstream: `minTipLamportsMax` is 1,000,000 and `minTipLamportsSwqos` is 5,000. `sendViaSender` / `sendTransactionWithSender` accept `skipPreflight`, defaulting to `true` (upstream #335).
- Adds `PreconfWsClient` / `preconfSubscribe` for subscribing to preconfirmation websocket notifications with `preconfWebsocketUrl` and wire-format helpers `decodePreconfFrame`, `preconfWireVersion`, and `preconfHeadLength` (upstream #335).

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #221](https://github.com/openbudgetfun/solana_kit/pull/221) · _Related issues:_ [#334](https://github.com/openbudgetfun/solana_kit/issues/334), [#335](https://github.com/openbudgetfun/solana_kit/issues/335), [#336](https://github.com/openbudgetfun/solana_kit/issues/336), [#341](https://github.com/openbudgetfun/solana_kit/issues/341)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## solana_kit_helius [0.6.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.6.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_helius` was updated to 0.6.1.

## solana_kit_helius [0.6.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.6.2) (2026-09-06)

### 🐛 Fixed

#### Reject failed Helius transaction confirmations

Reject failed on-chain transactions during transaction and bundle confirmation instead of returning successful results. Accept confirmed signatures when processed commitment is requested.

Redact API keys and URL credentials from JSON-RPC and REST connection exceptions, and omit URL credentials from WebSocket connection errors.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Fix Helius preconfirmation lifecycle

Handle preconfirmation WebSocket readiness, stream, send, and shutdown failures without exposing endpoint credentials or leaving pending requests unresolved. Wait for connection readiness before sending, close notification streams on terminal failures, encode API-key query values safely, and support an injectable channel connector.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Harden load-sensitive Helius websocket tests

Two Helius websocket tests failed on a loaded CI runner while passing locally: the connection-failure test raced the kernel completing handshakes queued before `HttpServer.close(force: true)` (so `connect()` occasionally succeeded instead of refusing), and the preconf websocket tests enforced 5-second timeouts that expired under load. The port-close test now probes the port until it provably refuses connections before asserting the failure path, and the preconf stream timeouts — which exist only to prevent hangs — are widened to 30 seconds.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #241](https://github.com/openbudgetfun/solana_kit/pull/241) · _Related issues:_ [#240](https://github.com/openbudgetfun/solana_kit/issues/240)

## solana_kit_helius [0.6.3](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.6.3) (2026-09-12)

### Changed

- **No package-specific changes were recorded; `solana_kit_helius` was updated to 0.6.3.**

## solana_kit_helius [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_helius/v0.7.0) (2026-09-21)

### Breaking changes

#### Raise the Dart and Flutter baseline

The workspace now builds against Dart 3.13.3 and Flutter 3.47.4, and every package declares that floor instead of the previous Dart 3.12 range. Consumers on older SDKs can no longer resolve these packages, so this release is breaking even though no Dart API changed.

The Flutter floor rises from 3.44 to 3.47 for `solana_kit_mobile_wallet_adapter`, `solana_kit_mobile_wallet_adapter_protocol`, and `solana_kit_wallet_adapter`, matching the floor `solana_kit_wallet_ui` already required. `solana_kit_lints` ships the raised floor to consumers, so it carries the same breaking bump. Every other package raises only the Dart SDK floor.

Raising the language version also switches `dart format` to the tall style, so 83 files across library, test, script, and Codama-generated trees are reflowed. The renderer pipes generated output through `dart format`, so regenerating stays consistent.

Align your own SDK constraint with the workspace:

```yaml
environment:
  sdk: ^3.13.0
  # Omit for pure Dart packages; required for the Flutter packages above.
  flutter: ">=3.47.0"
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [5f5fe01](https://github.com/openbudgetfun/solana_kit/commit/5f5fe01f3e2220ccfee54cc26e82c3face26589d) · _Last updated in:_ [19932db](https://github.com/openbudgetfun/solana_kit/commit/19932dba1979f1190b7501947b87eb8a4d4cc8d5)

### Features

#### Replace stubbed functions with real implementations

Several public functions promised behavior they did not deliver. Each is now implemented, with the missing API surface added alongside it.

##### `estimateResourceLimitsFactory` now simulates

The previous implementation returned its argument unchanged, so it performed no simulation: no compute unit measurement, no loaded accounts data size, no failure reporting. It also could not have worked where it lived, because it needs an RPC client and the transaction compiler, and `solana_kit_transaction_messages` depends on neither. Upstream defines this function in the umbrella `@solana/kit` package for the same reason, so it now lives in `package:solana_kit` with that dependency available.

It takes an `EstimateResourceLimitsFactoryConfig` holding the RPC client and returns a function that:

- Sets the compute unit limit to the maximum (`1400000`) and, for version 1 messages, the loaded accounts data size limit to the maximum (`67108864`) before simulating, so the simulation is not cut short by a resource ceiling.
- Asks the node to replace the blockhash for blockhash-lifetime transactions, and uses the real nonce for durable nonce transactions.
- Returns the `unitsConsumed` the node reported, capped at the `u32` ceiling, plus `loadedAccountsDataSize`.
- Throws `transactionFailedToEstimateComputeLimit` when the node reports no compute units, `transactionFailedToEstimateLoadedAccountsDataSizeLimit` when a version 1 simulation omits the loaded accounts size, and `transactionFailedWhenSimulatingToEstimateResourceLimits` with the decoded transaction error as `cause` when the transaction itself fails. All three codes already existed and were never thrown.

Three supporting pieces land with it:

- `simulateTransaction` and its `simulateTransactionValue` result are now available on the RPC client. The method was reachable only by hand-assembling a request before this.
- `maxLoadedAccountsDataSizeLimit` (`67108864`) is exported.
- `estimateAndSetResourceLimitsFactory` no longer computes a loaded accounts data size for legacy and version 0 messages. It previously did, which spent an extra simulation and could attach a `SetLoadedAccountsDataSizeLimit` instruction the runtime ignores. The loaded accounts limit is now only ever set on version 1 messages, matching upstream.

```dart
final estimate = estimateResourceLimitsFactory(
  EstimateResourceLimitsFactoryConfig(rpc: rpc),
);
final withLimits = await estimateAndSetResourceLimitsFactory(estimate)(message);
```

##### `solana_kit_functional` removed

The package is gone. Its only utility, the `pipe` extension, has lived in `solana_kit_transaction_messages` since the previous breaking release and is re-exported by `solana_kit`, so the package duplicated what the SDK already provided and existed only as an empty placeholder pending retirement. Anyone still importing it should switch to `solana_kit_transaction_messages` (or the `solana_kit` umbrella), which is a one-line import change.

##### `solana_kit_addresses` gains the PDA guards

`isProgramDerivedAddress` and `assertIsProgramDerivedAddress` were absent, leaving `addressesMalformedPda` and `addressesPdaBumpSeedOutOfRange` defined but unreachable. Both are now implemented: they validate that a value is an `(Address, int)` record, that the bump seed is in `[0, 255]`, and that the address is well formed.

##### `solana_kit_helius` builds real smart transactions

`createSmartTransaction` returned a bare blockhash while documenting that it would estimate compute units and priority fees. It now performs the full sequence: validate, estimate compute units through `simulateTransaction`, sample the priority fee by account key, resolve the fee in both microLamports-per-unit and total lamports, and refresh the blockhash. It returns a `SmartTransaction` carrying the limits, fee, lifetime, instructions, fee payer, and account keys; signing stays with the caller because the client holds signer addresses rather than keys.

Two related silent defaults were removed:

- `getComputeUnits` returned `200000` when the node omitted `unitsConsumed`. It now throws, because inventing a number sizes the transaction for work the simulation never confirmed. It also reports a failed simulation instead of returning the units of one that did not succeed, and it serializes real `Instruction` objects, which previously failed at JSON encoding.
- `broadcastTransaction`, `sendTransactionWithSender`, and `sendSmartTransaction` accepted a `senderUrl` parameter they never used. The parameter is gone; the REST client already targets the sender base URL.

##### Version 1 durable nonce transactions are recognized

`getTransactionLifetimeConstraintFromCompiledTransactionMessage` only inspected the legacy instruction list, which a version 1 compiled message leaves empty in favour of separate instruction headers and payloads. Every version 1 durable nonce transaction therefore decompiled as a blockhash transaction, so a caller could not tell that its lifetime depended on a nonce. The version 1 branch now reads the headers and payloads, throws `transactionInvalidNonceAccountIndex` for an out-of-range nonce account index, and returns the blockhash lifetime only when the first instruction is genuinely not an advance-nonce instruction.

##### Priority fee lamports API

`getTransactionMessagePriorityFeeLamports` and `setTransactionMessagePriorityFeeLamports` add the missing read/write surface for the total-lamport priority fee that only version 1 messages carry. The setter removes the fee on `null`, drops an emptied config, and is a no-op when the value already matches.

##### Wallets can now express and check version 1 support

`SolanaTransactionVersion` gains `version1` plus `wireValue` and `fromWireValue`, so the values a wallet advertises (`legacy`, `0`, `1`) round-trip instead of being collapsed. A `supportsVersion1` extension makes the check usable. Two related corrections:

- The browser registry used to map any advertised entry other than `legacy` onto version 0, so a wallet advertising `1` was reported as version 0 and a caller could build a transaction the wallet cannot sign. Unrecognized entries are now dropped rather than mislabelled.
- The MWA-backed mobile wallet advertises an explicit `legacy`-and-version-0 list instead of `SolanaTransactionVersion.values`, which would have silently started claiming version 1 support as the enum grew. This matches upstream's `wallet-standard-mobile`.

##### Error codes that were defined but unreachable

Three codes had no throw site. `signerWalletAccountCannotSignTransaction` is now thrown when a `WalletAccountSigner` is created for an account advertising neither transaction feature, matching upstream's `createSignerFromWalletAccount`. `heliusApiKeyRequired` is thrown by `HeliusConfig` for a blank key, which previously produced a request that could only fail with a 401. `heliusTransactionSimulationFailed` replaces a bare `StateError` when a compute-unit simulation reports a transaction failure.

The remaining defined-but-unthrown codes were checked against upstream and are parity-faithful: upstream defines them without throwing them anywhere either (`addressesInvalidBase58EncodedAddress`, the four `wallet*` codes, `subscribableRetryNotSupported`, `transactionInvalidNonceTransactionFirstInstructionMustBeAdvanceNonce`), or they belong to abstractions this port intentionally does not have (the React hook path behind `signerWalletMultisignUnimplemented`, the fs-impl package behind `fsUnsupportedEnvironment`, the named-channel pubsub plan behind `invariantViolationDataPublisherChannelUnimplemented`).

##### `solana_kit_dapp_publisher_cli` reports unreadable balances

`parseLamportsValue` returned `0` for a balance response it could not parse. A malformed response therefore looked like an empty wallet. It now throws a `FormatException`, so a transport or schema change is reported as itself rather than as insufficient funds.

_Owner:_ Ifiok Jr. · _Introduced in:_ [19932db](https://github.com/openbudgetfun/solana_kit/commit/19932dba1979f1190b7501947b87eb8a4d4cc8d5)

### Fixes

- **Await the sender service call before disposing the signing keypair.** `buildTokenTransfer` now awaits `sendViaSender` inside the `try` block instead of returning the Future directly, so the ephemeral keypair is disposed after the send completes rather than at return time. Signing already finishes before the call, so this is a lifecycle hygiene change with no observable behavior difference; it satisfies the Dart 3.13 `unawaited_return_in_try_block` diagnostic that the Flutter 3.47 toolchain enables. _Owner:_ Ifiok Jr. · _Introduced in:_ [e041e73](https://github.com/openbudgetfun/solana_kit/commit/e041e731bb0291af05c06c16d7042fdbf51166a1)
