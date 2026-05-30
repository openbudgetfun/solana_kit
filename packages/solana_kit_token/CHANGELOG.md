# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_token [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_token/v0.4.0) (2026-05-30)

### 💥 Breaking Change

#### New package available

SPL Token and Associated Token Account client for the Solana Kit Dart SDK. Generated from the upstream Codama IDL with handwritten ergonomic helpers for common token operations.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🚀 Feature

#### Add associated token account package

Add a handwritten solana_kit_associated_token_account…

Add a handwritten `solana_kit_associated_token_account` package and switch `solana_kit_token` / `solana_kit_token_2022` to share its ATA PDA helpers and instruction builders.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`0e6a808`](https://github.com/openbudgetfun/solana_kit/commit/0e6a808224c80df6cfb0c04f84a2debe5433c26b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 🐛 Fixed

#### Improve handwritten test coverage across RPC

_Owner:_ Ifiok Jr. · _Introduced in:_ [`68fa2e3`](https://github.com/openbudgetfun/solana_kit/commit/68fa2e39683da95e11b79ec3d45e03624948cbe9) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Add generated-code test coverage for token

Add comprehensive generated-code test coverage for…

Add comprehensive generated-code test coverage for solana_kit_token (instructions, accounts, types, PDAs) and solana_kit_system (codec round-trips, parse round-trip, program constants).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`d930a56`](https://github.com/openbudgetfun/solana_kit/commit/d930a56035d5e4a34121be2a4d9ffcd30c0ad592) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
