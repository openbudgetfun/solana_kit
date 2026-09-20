# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.10.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.10.0) (2026-09-21)

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

#### Speed up base-X codecs, BigInt JSON parsing, and fixed-point parsing

Same results, less work per call. No public API, output byte, or error behavior changed; `upstream:parity` passes against `@solana/kit@8.3.0` and the full workspace suite is green.

The base-X codecs converted through `BigInt`, scaled the alphabet with `String.indexOf` and a fresh one-character string per input character, and built output with repeated `insert(0, …)` calls that reallocate and shift the whole list each time. Encoding a typical base58 address cost roughly 600 µs, so compiling a 20-account transaction spent measurable milliseconds on address encoding alone. The conversion now folds digits into a byte buffer with word-sized carry arithmetic, indexes the alphabet through a cached code-unit lookup, and writes output in order:

```dart
// Before: BigInt division per character plus O(n²) list inserts.
// After: one carry pass per character over a preallocated buffer.
final converted = _convertToBytes(value, alphabet);
bytes
  ..fillRange(offset, offset + converted.leadingZeroes, 0)
  ..setAll(offset + converted.leadingZeroes, converted.bytes);
```

Measured on an interleaved best-of-N benchmark, with the previous implementation running in the same process to cancel machine noise:

| Operation                        | Before   | After   | Improvement |
| -------------------------------- | -------- | ------- | ----------- |
| base58 encode, typical address   | 22.97 µs | 2.88 µs | 8.0x        |
| base58 decode, 32 bytes          | 16.79 µs | 3.24 µs | 5.2x        |
| base58 encode, 64-byte signature | 52.89 µs | 8.44 µs | 6.3x        |

`parseJsonWithBigInts` allocated a one-character string and ran up to two regular expressions per character of the payload, then rebuilt the document character by character. It now scans by code unit, copies literal runs as substrings, and hoists the exponent pattern:

| Operation                 | Before   | After    | Improvement |
| ------------------------- | -------- | -------- | ----------- |
| parse a 28 KB RPC payload | 2.198 ms | 1.089 ms | 2.0x        |

Also removed in the same pass: a redundant full copy in the UTF-8 encoder and the base64 decoder (both `utf8.encode` and `base64.decode` already return `Uint8List`), a double copy of every version-1 instruction payload, and two regular expressions that were compiled per parsed value in the fixed-point codecs.

Behavior is pinned by tests rather than assumed. `base_x_property_test.dart` round-trips random byte strings across every length from 0 to 512 bytes, covers leading-zero-only input, alphabets wider than a byte, and non-power-of-two alphabets, and asserts arbitrary-precision digit strings beyond 64 bits. A degenerate one-character alphabet is now rejected with an `ArgumentError` when the codec is created; previously it produced silent zero output on encode and looped forever on decode.

`bench:all` also gains coverage where the regression was invisible: the address benchmark previously measured only the all-ones System Program address, which is base58's leading-zero fast path and exercises no base conversion at all.

_Owner:_ Ifiok Jr. · _Introduced in:_ [b22257e](https://github.com/openbudgetfun/solana_kit/commit/b22257e1d1cb146eda742cd3da352b6a90a49f1d)

## [0.9.3](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.3) (2026-09-12)

### Changed

- **No package-specific changes were recorded; `solana_kit_addresses` was updated to 0.9.3 as part of group `main`.**

## [0.9.2](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.2) (2026-09-06)

### 🐛 Fixed

#### Harden key verification and publication

Reject small-order Ed25519 public keys and signature nonce points, including non-canonical aliases, to prevent weak-key signature forgery. Publish key files from a mode-`0700` staging directory so destination replacement cannot redirect secret bytes and readers of a file reservation cannot retain access to the completed key file.

Correct PDA documentation to state that callers may supply at most 15 seeds, reserving the sixteenth seed for the automatically appended bump.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

## [0.9.1](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_addresses` was updated to 0.9.1 as part of group `main`.

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## [0.8.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.8.0) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_addresses` was updated to 0.8.0 as part of group `main`.

## [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.7.0) (2026-08-18)

### 📖 Documentation

#### Reformat package docs

Docs have been reformatted to remove line wrapping.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #212](https://github.com/openbudgetfun/solana_kit/pull/212)

## [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.6.0) (2026-08-12)

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

### 🚀 Feature

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

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)
