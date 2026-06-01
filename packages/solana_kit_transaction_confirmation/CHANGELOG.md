# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.5.0) (2026-06-01)

### 🚀 Feature

#### Refactor subscriptions to stream-native APIs

Refactor subscription internals toward stream-native Dart APIs while keeping the existing `DataPublisher` and `AbortSignal` compatibility APIs available as deprecated APIs.

Added stream-native helpers for channel streams, demultiplexing, reactive stores, and data/error stream composition, and migrated internal subscription consumers to use Dart `Stream`/`StreamSubscription` flows where possible.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #173](https://github.com/openbudgetfun/solana_kit/pull/173) · _Closed issues:_ [#109](https://github.com/openbudgetfun/solana_kit/issues/109)

### 🧪 Testing

#### Improve test coverage to 95%+ across all packages

Added 500+ tests covering equality/hashCode/toString, codec edge cases, error paths, and constructor variants. Removed dead code in fast_stable_stringify. Fixed concurrent modification bug in subscribable.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #166](https://github.com/openbudgetfun/solana_kit/pull/166)

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add ==

Add `==`, `hashCode`, and `toString` to `SignatureStatus` for structural equality support.

`SignatureStatus` now implements value-type equality based on its `confirmationStatus` and `err` fields. This enables correct behavior when using `SignatureStatus` instances in `Set`s, as `Map` keys, and in test assertions that compare expected vs. actual status values.

A `toString` override is also included for readable diagnostics during debugging and test failure output.

This completes the value-semantics initiative (issue #114) for the transaction confirmation package, which was listed in the original scope but omitted from the changeset frontmatter.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`5bccc42`](https://github.com/openbudgetfun/solana_kit/commit/5bccc42120e7bc038fc507719727500364a43bd9)
