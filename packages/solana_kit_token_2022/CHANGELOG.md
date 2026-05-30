# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_token_2022 [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_token_2022/v0.4.0) (2026-05-30)

### 💥 Breaking Change

#### New package available

SPL Token 2022 and Associated Token Account client for the Solana Kit Dart SDK. Generated from the upstream Codama IDL with focused ergonomic helpers for Token 2022 extensions and operations.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🚀 Feature

#### Add generated Token-2022 package

Add a generated solana_kit_token_2022 package from the…

Add a generated `solana_kit_token_2022` package from the upstream Token-2022 Codama IDL, with focused helpers for mint/token sizing and pre-initialize mint extension instructions.

Also fix Dart Codama renderer support for Token-2022 by handling constant hidden affixes, bytes discriminators, robust enum/discriminated-union generation, zero-field enum/struct cases, and non-const instruction discriminator defaults.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`4663211`](https://github.com/openbudgetfun/solana_kit/commit/4663211ef8d2673063d424e0dbf5e3a55efa1c9b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add associated token account package

Add a handwritten solana_kit_associated_token_account…

Add a handwritten `solana_kit_associated_token_account` package and switch `solana_kit_token` / `solana_kit_token_2022` to share its ATA PDA helpers and instruction builders.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`0e6a808`](https://github.com/openbudgetfun/solana_kit/commit/0e6a808224c80df6cfb0c04f84a2debe5433c26b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)
