# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-28)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910)

#### Add key-pair filesystem and grinding compatibility helpers, including writing key pairs to disk with Solana-compatible JSON byte arrays and grinding generated key pairs until they match a predicate.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)

#### SEC-02: Add Finalizer-based memory zeroing for KeyPair private keys.

- Added `Finalizer` that zeros internal key bytes when `KeyPair` is garbage collected
- Added `dispose()` method to explicitly zero key bytes on demand
- Added `isDisposed` property to check if `dispose()` has been called
- `privateKey` and `publicKey` getters now throw `StateError` after `dispose()`
- Documented limitations of Dart's GC-based finalization
- 4 new tests covering dispose behavior

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3c175c3`](https://github.com/openbudgetfun/solana_kit/commit/3c175c3a852f04df89145f1edc5c458abaab253d)
