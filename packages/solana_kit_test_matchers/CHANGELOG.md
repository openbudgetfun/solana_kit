# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.5.0) (2026-06-01)

### 🧪 Testing

#### Refactor subscriptions to stream-native APIs

Refactor subscription internals toward stream-native Dart APIs while keeping the existing `DataPublisher` and `AbortSignal` compatibility APIs available as deprecated APIs.

Added stream-native helpers for channel streams, demultiplexing, reactive stores, and data/error stream composition, and migrated internal subscription consumers to use Dart `Stream`/`StreamSubscription` flows where possible.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #173](https://github.com/openbudgetfun/solana_kit/pull/173) · _Closed issues:_ [#109](https://github.com/openbudgetfun/solana_kit/issues/109)

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add shared test fixtures and coverage gates

Add shared workspace test fixtures plus risk-tier package…

Add shared workspace test fixtures plus risk-tier package coverage gates so high-risk Solana Kit packages stay above 90% line coverage in CI.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ba96efb`](https://github.com/openbudgetfun/solana_kit/commit/ba96efba2e88ada3944ab2a9b0694d18d315a89d) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add shared test helpers (FakeRpcTransport

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)
