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

### 🧪 Testing

#### Improve test coverage to 95%+ across all packages

Added 500+ tests covering equality/hashCode/toString, codec edge cases, error paths, and constructor variants. Removed dead code in fast_stable_stringify. Fixed concurrent modification bug in subscribable.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`48216f9`](https://github.com/openbudgetfun/solana_kit/commit/48216f9af0ff058d7db83994e5bdb3b9be95fdf8) · _Last updated in:_ [`b7f5419`](https://github.com/openbudgetfun/solana_kit/commit/b7f5419bbe792d4ba1731eba227088d8f74a3ebb)

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 🚀 Feature

#### Replace string encoding fields with AccountEncoding

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

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

#### Expand RPC API test coverage

Expand RPC API test coverage with per-method config/params tests and shared param-builder contract tests.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Replace unsafe .cast() with JsonReader

Introduce internal JsonReader helper that replaces unsafe…

Introduce internal `JsonReader` helper that replaces unsafe `.cast<T>()` list

casts and bare `as` casts in all `fromJson` factories with explicit typed
accessors. Parse errors now surface at construction time via a descriptive
`FormatException` that includes the field name, rather than deferring until
element access. All ten type files (`das_types`, `enhanced_types`, `zk_types`,
`wallet_types`, `webhook_types`, `rpc_v2_types`, `auth_types`, `staking_types`,
`priority_fee_types`, `smart_transaction_types`) have been migrated. The public
API is unchanged.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Replace dynamic with Object?

Replace dynamic with Object? across lib source files; remaining dynamic usage is only in test matcher API signatures required by the test package.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fe249a4`](https://github.com/openbudgetfun/solana_kit/commit/fe249a46e06edf2f4cc924b30c4c463e8ea9a910) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add equality to value types

Add == / hashCode / toString to value types across…

Add == / hashCode / toString to value types across rpc_types, rpc_api, rpc_parsed_types, rpc_spec_types, instructions, transaction_messages, and transaction_confirmation.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add account client and RPC response models

Add a higher-level Solana account client plus typed RPC…

Add a higher-level Solana account client plus typed RPC response wrappers for common account, balance, blockhash, and multi-account request flows.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`aa54336`](https://github.com/openbudgetfun/solana_kit/commit/aa54336c1e9a6c4ae5df1adafc1822cfccf342fa) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Align sendTransaction and simulate with 6.9

Align sendTransaction and simulateTransaction behavior…

Align sendTransaction and simulateTransaction behavior with upstream 6.9, including preflight metadata defaults, nullable Agave metadata, BigInt JSON-RPC error code handling, and expanded simulation response metadata types.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
