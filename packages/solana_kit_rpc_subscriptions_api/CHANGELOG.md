# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 💥 Breaking Change

#### Replace string encodings with typed enums

Replace string encoding fields with typed enums in…

Replace string encoding fields with typed enums in subscription notification config classes.

The `encoding` field on `AccountNotificationsConfig`, `BlockNotificationsConfig`, and `ProgramNotificationsConfig` has been changed from `String?` to `AccountEncoding?` or `TransactionEncoding?` respectively. This is a breaking change: callers that previously passed raw strings like `'base64'` or `'jsonParsed'` must now use the corresponding enum values such as `AccountEncoding.base64` or `AccountEncoding.jsonParsed`.

This aligns the subscriptions API with the same encoding-enum migration applied to the RPC request API, ensuring consistent type safety across both surfaces. The wire format is unchanged — the enums serialize to the same JSON strings — so no server-side compatibility is affected.

Migration example:

```dart
// Before
AccountNotificationsConfig(encoding: 'base64')
// After
AccountNotificationsConfig(encoding: AccountEncoding.base64)
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)
