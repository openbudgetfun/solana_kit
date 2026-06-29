# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.6.0) (2026-06-29)

### 💥 Breaking Change

#### Remove deprecated APIs across the SDK

**Breaking change.** Clears every `remove_deprecations_in_breaking_versions`
lint warning by deleting deprecated members and migrating call sites to their
documented replacements. No deprecations are suppressed; each deprecated
declaration is removed.

##### `createEmptyClient` (solana_kit)

Removed the deprecated `createEmptyClient` alias. Use `createClient` instead.

```dart
// Before
final client = createEmptyClient({'ready': true});
// After
final client = createClient({'ready': true});
```

##### Deprecated fixed-point rounding modes (solana_kit_fixed_points)

Removed the deprecated `FixedPointRoundingMode` values `down`, `up`, and
`halfUp`. The surviving modes are `strict`, `floor`, `ceil`, `trunc`, `round`.

- `down` was a duplicate of `trunc` — use `FixedPointRoundingMode.trunc`.
- `halfUp` was a duplicate of `round` — use `FixedPointRoundingMode.round`.
- `up` ("round away from zero") has no single replacement. Use `floor` or
  `ceil` depending on the sign of the value, or `round` for nearest.

##### Deprecated `Pipe` extension (solana_kit_functional)

Removed the deprecated `Pipe` extension from `solana_kit_functional`. `Pipe` is
re-exported from `solana_kit_transaction_messages` and the `solana_kit` umbrella.
Switch imports accordingly:

```dart
// Before
import 'package:solana_kit_functional/solana_kit_functional.dart';
// After
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
```

`solana_kit` no longer depends on `solana_kit_functional`. The
`solana_kit_functional` package is now an empty placeholder pending full
retirement.

##### Deprecated subscriptions compatibility APIs

The deprecated `AbortSignal`/`AbortController` and
`DataPublisher`/`WritableDataPublisher`/`createDataPublisher` compatibility
APIs were the core transport substrate of the subscriptions stack, not a thin
compatibility layer. They are replaced by stream-native and cancellation-token
equivalents.

###### Cancellation

- `AbortSignal` → `CancellationToken` (from `solana_kit_subscribable`)
- `AbortController` → `CancellationTokenSource` (from `solana_kit_subscribable`)
- `controller.signal` → `source.token`
- `controller.abort([reason])` → `source.cancel([reason])`
- `signal.isAborted` → `token.isCancelled`
- `signal.reason` → `token.reason`
- `signal.future` → `token.future`

Public field/parameter names that held an `AbortSignal` (e.g. `abortSignal`,
`signal`) are kept; only their type changed to `CancellationToken`.
`CancellationToken` and `CancellationTokenSource` are re-exported from
`solana_kit_rpc_subscriptions` and `solana_kit_rpc_subscriptions_channel_websocket`
so consumers do not need a direct `solana_kit_subscribable` dependency.

`AbortError`, `isAbortError`, `getAbortableFuture`, and `normalClosureCode`
remain in `solana_kit_rpc_subscriptions_channel_websocket` (behavior unchanged;
their `AbortSignal?` params are now `CancellationToken?`).

###### DataPublisher → NotificationStreams

- The transport contract changed from `Future<DataPublisher>` to
  `Future<NotificationStreams>`.
- `RpcSubscriptionsChannel` now exposes `NotificationStreams get streams`
  instead of the `on(channelName, subscriber)` method.
- `createDataPublisher()`, `WritableDataPublisher`, `DataPublisher`, and the
  `DataPublisherStreams` extension are removed.
- The `*FromDataPublisher` helpers are removed:
  `createStreamFromDataPublisher`, `StreamFromDataPublisherConfig`,
  `createAsyncIterableFromDataPublisher`, `demultiplexDataPublisher`,
  `createReactiveStoreFromDataPublisher`,
  `createReactiveStreamStoreFromDataPublisher`.
- The stream-native helpers are kept: `ChannelStreamController`,
  `createStreamFromDataAndErrorStreams`, `demultiplexStream`,
  `createReactiveStoreFromStreams`, `ReactiveStore`, `ReactiveStreamStore`,
  `createReactiveStreamStore`.

###### Public subscription APIs

`PendingRpcSubscriptionsRequest.subscribe()` and `.reactive()` still return
`Future<Stream<T>>` and `Future<ReactiveStore<T>>` respectively. Internally they
now consume `NotificationStreams.notifications` / `.errors` instead of
`DataPublisher` channels.

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

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3901c24`](https://github.com/openbudgetfun/solana_kit/commit/3901c24a64bf94f8772611f62bd8d289f10fdbb8)

### 🚀 Feature

#### Upstream @solana/kit 6.10.0 parity

Updates core packages to match upstream `@solana/kit` `6.10.0`:

- **solana_kit_errors**: Adds 6 new error codes from `@solana/errors` 6.10:
  `JSON_RPC__SERVER_ERROR_NO_SLOT_HISTORY` (-32021),
  `JSON_RPC__SERVER_ERROR_FILTER_TRANSACTION_NOT_FOUND` (-32020),
  `TRANSACTION__FAILED_TO_ESTIMATE_LOADED_ACCOUNTS_DATA_SIZE_LIMIT` (5663036),
  `TRANSACTION__FAILED_WHEN_SIMULATING_TO_ESTIMATE_RESOURCE_LIMITS` (5663037),
  `SUBSCRIBABLE__RETRY_NOT_SUPPORTED` (8195000),
  `WALLET__ACCOUNT_NOT_AVAILABLE` (8900003).
  Adds `subscribable` and `wallet` error domains. Updates
  `unwrapSimulationError` to treat resource-limit simulation failures as
  simulation errors.

- **solana_kit_subscribable**: Adds `ReactiveActionStore<TArgs, TResult>` with
  idle/running/success/error states, `dispatch`/`dispatchAsync`/`reset`.
  Adds `ReactiveStreamStore<T>` with loading/loaded/error/retrying states,
  `getUnifiedState` and `retry`. Mirrors upstream `@solana/subscribable` 6.10.

- **solana_kit_rpc_spec**: Adds `PendingRpcRequest.reactiveStore()` returning a
  `ReactiveActionStore` for reactive request dispatch.

- **solana_kit_rpc_api**: Adds `clientId` to `ClusterNode`. Documents `tpu` and
  `tpuForwards` as deprecated in favor of QUIC fields.

- **solana_kit_transaction_messages**: Adds resource-limit estimation helpers:
  `ResourceLimitsEstimate`, `estimateResourceLimitsFactory`,
  `estimateAndSetResourceLimitsFactory`,
  `fillTransactionMessageProvisoryResourceLimits`,
  `getTransactionMessageLoadedAccountsDataSizeLimit`,
  `setTransactionMessageLoadedAccountsDataSizeLimit`.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`89b3457`](https://github.com/openbudgetfun/solana_kit/commit/89b3457135968f975f0a002a1ef1b33072de6320)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`914f224`](https://github.com/openbudgetfun/solana_kit/commit/914f224a81e16a40c21554cd6766845ead05a6e9)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a4c5169`](https://github.com/openbudgetfun/solana_kit/commit/a4c5169c0e891c211f39958219268ae9ad8b9934)

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

#### Refactor subscriptions to stream-native APIs

Refactor subscription internals toward stream-native Dart APIs while keeping the existing `DataPublisher` and `AbortSignal` compatibility APIs available as deprecated APIs.

Added stream-native helpers for channel streams, demultiplexing, reactive stores, and data/error stream composition, and migrated internal subscription consumers to use Dart `Stream`/`StreamSubscription` flows where possible.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fcc74a`](https://github.com/openbudgetfun/solana_kit/commit/6fcc74a6860a5201fdfff03a56411f2084da5444) · _Last updated in:_ [`9988103`](https://github.com/openbudgetfun/solana_kit/commit/99881033c4f8a121f811c217a19c092c629103e4)

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

#### Document stream-first subscription preference

Document stream-first preference in solana_kit_subscribable and rpc_subscriptions; DataPublisher remains as a compatibility layer.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`12316d5`](https://github.com/openbudgetfun/solana_kit/commit/12316d50aadfeefc7563665fbad750e37cba1fd5)

#### Add reactive store for subscription flows

Add the reactive store helper used by slot-tracking…

Add the reactive store helper used by slot-tracking RPC/subscription flows, including subscriber notification, initial value, and update coverage.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
