# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

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

### 🚀 Feature

#### Add SolanaAccountClient for account fetching

Add SolanaAccountClient as the single implementation…

Add `SolanaAccountClient` as the single implementation layer for `fetchEncodedAccount`, `fetchEncodedAccounts`, `fetchJsonParsedAccount`, and `fetchJsonParsedAccounts`, delegating all RPC calls through typed API methods instead of raw request maps. Extract `FetchAccountConfig` into its own file. Migrate parse helpers from `Map<String, dynamic>` to `Map<String, Object?>`. Switch error construction to the standardized `createSolanaError` and `wrapSolanaError` helpers with `SolanaErrorContextKeys`.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)
