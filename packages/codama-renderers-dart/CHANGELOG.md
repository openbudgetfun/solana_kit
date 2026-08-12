# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## codama-renderers-dart [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/codama-renderers-dart/v0.4.0) (2026-05-30)

### 💥 Breaking Change

#### New package available

Codama renderer for generating Dart code targeting the solana_kit SDK. Enables automatic generation of type-safe Dart client code from Codama IDL definitions.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add Codama IDL acceptance fixtures

Add comprehensive Codama IDL acceptance fixtures for SPL…

Add comprehensive Codama IDL acceptance fixtures for SPL Token, Token-2022, and System programs.

Three new Codama JSON IDL fixtures are added under `test/fixtures/`:

- **`spl_token.json`** + `spl_token.meta.json` — Full SPL Token program IDL (shank origin, 34 extensions, ATA program, associated types, errors)
- **`token_2022.json`** + `token_2022.meta.json` — Full Token-2022 program IDL (js@v0.9.0, 35 extensions including confidential transfers, metadata pointer, token groups, pausable config, scaled UI amounts)
- **`system.json`** + `system.meta.json` — Full System Program IDL (js@v0.12.0, 13 instructions, Nonce account types, 9 error codes)

Each fixture includes a `.meta.json` provenance file recording the source repository, git commit, tag, file path, and SHA-256 hash for traceability.

These fixtures expand the renderer's acceptance test surface from a single SPL Token fixture to three real-world Solana programs covering diverse IDL features: nested enum variants with size-prefixed structs, zeroable option types, map types with prefixed counts, multiple additional programs, PDA definitions with seed derivation, and error code catalogs. The expanded coverage catches rendering edge cases that simpler IDLs do not exercise.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Make Codama renderer production-ready

Make codama-renderers-dart production-ready for real…

Make codama-renderers-dart production-ready for real Solana program IDLs.

- Pin upstream SPL Token Codama JSON as acceptance fixture with provenance metadata
- Fix nullable codec type inference by emitting explicit type parameters
- Fix double-`??` on nullable optional instruction parameters
- Fix local variable shadowing in instruction builders and PDA helpers
- Add SPL Token acceptance test with dart analyze gate (28→0 errors)
- Add JS-vs-Dart structural parity tests for the SPL Token fixture
- Expose surfpool in devenv shell for validator-backed testing

_Owner:_ Ifiok Jr. · _Introduced in:_ [`c02af42`](https://github.com/openbudgetfun/solana_kit/commit/c02af42fc361fe016f54cfdfe0ad9b6ce2d1c13e) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add per-package codecov flags

Add Codecov patch coverage and package-level coverage…

Add Codecov patch coverage and package-level coverage flags for Dart and renderer packages.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`30e1d19`](https://github.com/openbudgetfun/solana_kit/commit/30e1d192192800481fbdc6afa57dc1a1fd255986) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

## codama-renderers-dart [0.4.1](https://github.com/openbudgetfun/solana_kit/releases/tag/codama-renderers-dart/v0.4.1) (2026-06-01)

### 🚀 Feature

#### Add well-known program, sysvar, SPL, Metaplex, and token mint address constants

Add centralized address constants to `solana_kit_addresses` so that any package can reference well-known on-chain addresses without importing the full domain package or hardcoding strings.

New exports:

- `program_addresses.dart` — All Agave/Solana native program addresses (system, ALT, BPF loaders, compute budget, config, stake, vote, etc.)
- `sysvar_addresses.dart` — All sysvar addresses (clock, rent, recentBlockhashes, fees, rewards, etc.) plus the sysvar owner address
- `spl_addresses.dart` — SPL program addresses (Token, Token-2022, ATA, Memo, Memo Legacy)
- `metaplex_addresses.dart` — Metaplex program addresses (Token Metadata, Bubblegum, Auth Rules, Core, SPL Account Compression, Noop)
- `well_known_addresses.dart` — Well-known token mint addresses (Wrapped SOL, USDC, USDT)

Also re-exports from `solana_kit_address` (Address type, codecs, comparator, PublicKey) and `solana_kit_address_constants` (well-known address constants).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3f596ef`](https://github.com/openbudgetfun/solana_kit/commit/3f596ef95c0d00714db97a4338ac9342f1fabfb7) · _Last updated in:_ [`4643648`](https://github.com/openbudgetfun/solana_kit/commit/46436481a28eab1c803175bee56e98e89fe8fac6)
