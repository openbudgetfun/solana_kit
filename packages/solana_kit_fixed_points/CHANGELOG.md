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

### Fixes

- **Document program errors and the generated program-client contract.** Add library doc comments synchronized from shared MDT sections to thirteen packages: program error matching (`isProgramError` + `TransactionMessageInput`) and the generated program-client API shape are now documented inline in each library and in the errors docs page; six barrels that had no library doc comment gain one; three one-line library headers are expanded. No code changes. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #248](https://github.com/openbudgetfun/solana_kit/pull/248)

## [0.9.2](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.2) (2026-09-06)

### 🐛 Fixed

#### Validate fixed-point ranges

Reject signed fixed-point values outside their declared range before encoding, preventing positive and negative values from wrapping into the opposite sign on the wire. Validate fixed-point shapes in assertion helpers and reject digit-free decimal input instead of parsing it as zero. Add regression tests for both fixed-point representations, byte orders, and signed range boundaries.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

## [0.9.1](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_fixed_points` was updated to 0.9.1 as part of group `main`.

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## [0.8.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.8.0) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_fixed_points` was updated to 0.8.0 as part of group `main`.

## [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.7.0) (2026-08-18)

### 📖 Documentation

#### Reformat package docs

Docs have been reformatted to remove line wrapping.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #212](https://github.com/openbudgetfun/solana_kit/pull/212)

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

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 🐛 Fixed

#### Add fixed-point helper package

Add the fixed-point helper package that ports…

Add the fixed-point helper package that ports @solana/fixed-points APIs, including binary and decimal fixed-point arithmetic, conversions, comparisons, formatting, codecs, parsing helpers, rounding, and raw range utilities.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
