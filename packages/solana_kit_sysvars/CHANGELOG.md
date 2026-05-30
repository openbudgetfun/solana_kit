# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_sysvars [0.3.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_sysvars/v0.3.2) (2026-05-30)

### 🚀 Feature

#### Detached from main group

This package is now released independently rather than as part of the main solana_kit group. System variable access is a standalone utility package that does not depend on the core solana_kit release cycle, so an independent release track is more appropriate.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Improve handwritten test coverage across RPC

_Owner:_ Ifiok Jr. · _Introduced in:_ [`68fa2e3`](https://github.com/openbudgetfun/solana_kit/commit/68fa2e39683da95e11b79ec3d45e03624948cbe9) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Add sysvar layout mapping helpers

Add shared fixed-layout sysvar mapping helpers for typed…

Add shared fixed-layout sysvar mapping helpers for typed struct encoders/decoders plus reusable structured formatting utilities, and migrate representative sysvar models to use them.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`f440ae7`](https://github.com/openbudgetfun/solana_kit/commit/f440ae7dc60c7a90014e76e669896b694761202e) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
