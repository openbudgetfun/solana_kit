# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.6.0) (2026-07-23)

### 🐛 Fixed

#### Harden cryptographic input handling

Harden keypair file writes, validate malformed mobile wallet cryptographic inputs, and update vulnerable renderer test dependencies.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #181](https://github.com/openbudgetfun/solana_kit/pull/181)

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

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add key-pair filesystem and grinding compatibility helpers

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Zero KeyPair private key memory on GC

SEC-02: Add Finalizer-based memory zeroing for KeyPair private keys.

- Added `Finalizer` that zeros internal key bytes when `KeyPair` is garbage collected
- Added `dispose()` method to explicitly zero key bytes on demand
- Added `isDisposed` property to check if `dispose()` has been called
- `privateKey` and `publicKey` getters now throw `StateError` after `dispose()`
- Documented limitations of Dart's GC-based finalization
- 4 new tests covering dispose behavior

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3c175c3`](https://github.com/openbudgetfun/solana_kit/commit/3c175c3a852f04df89145f1edc5c458abaab253d) · _Last updated in:_ [`12316d5`](https://github.com/openbudgetfun/solana_kit/commit/12316d50aadfeefc7563665fbad750e37cba1fd5)
