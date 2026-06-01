# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.5.0) (2026-06-01)

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

#### Add equality to value types

Add == / hashCode / toString to value types across…

Add == / hashCode / toString to value types across rpc_types, rpc_api, rpc_parsed_types, rpc_spec_types, instructions, transaction_messages, and transaction_confirmation.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add Agave v3 parsed vote-account fields

Add Agave v3 parsed vote-account fields and parsing coverage so vote account responses accept the new epoch credit and commission metadata returned by recent validators.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
