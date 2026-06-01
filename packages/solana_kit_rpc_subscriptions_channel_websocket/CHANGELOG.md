# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.5.0) (2026-06-01)

### 🚀 Feature

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

#### Improve handwritten test coverage across RPC

_Owner:_ Ifiok Jr. · _Introduced in:_ [`68fa2e3`](https://github.com/openbudgetfun/solana_kit/commit/68fa2e39683da95e11b79ec3d45e03624948cbe9) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Insecure WebSocket only in debug mode

SEC-04: Restrict allowInsecureWs to debug mode only.

- In release/profile mode, `ws://` URLs are now always rejected regardless of the `allowInsecureWs` flag
- Prevents accidental use of insecure WebSocket connections in production
- Updated documentation to reflect the debug-only behavior

_Owner:_ Ifiok Jr. · _Introduced in:_ [`f462724`](https://github.com/openbudgetfun/solana_kit/commit/f46272452cbc81021286b10e0e739b27b40c5b5b) · _Last updated in:_ [`12316d5`](https://github.com/openbudgetfun/solana_kit/commit/12316d50aadfeefc7563665fbad750e37cba1fd5)

#### SSRF protection for WebSocket URLs

SEC-05: Add SSRF protection for WebSocket URLs.

- Block connections to private/internal hosts by default (localhost, 10.x, 172.16-31.x, 192.168.x, 169.254.x, fc/fd::)
- Added `allowPrivateHosts` option to `WebSocketChannelConfig` for local development
- 5 new SSRF protection tests

_Owner:_ Ifiok Jr. · _Introduced in:_ [`e77206e`](https://github.com/openbudgetfun/solana_kit/commit/e77206e37c0f793e9dc2b6b1632131b20ef9b959) · _Last updated in:_ [`12316d5`](https://github.com/openbudgetfun/solana_kit/commit/12316d50aadfeefc7563665fbad750e37cba1fd5)

#### Add abortable websocket connection behavior

Add abortable websocket connection behavior and tests so subscription channels can be cancelled consistently with upstream promise abort helpers.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
