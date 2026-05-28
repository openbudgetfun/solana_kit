# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## codama-renderers-dart [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/codama-renderers-dart/v0.4.0) (2026-05-28)

### 💥 Breaking Change

#### New package available

Codama renderer for generating Dart code targeting the solana_kit SDK. Enables automatic generation of type-safe Dart client code from Codama IDL definitions.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`3c175c3`](https://github.com/openbudgetfun/solana_kit/commit/3c175c3a852f04df89145f1edc5c458abaab253d)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910)

#### Add comprehensive Codama IDL acceptance fixtures for SPL Token, Token-2022, and System programs.

Three new Codama JSON IDL fixtures are added under `test/fixtures/`:

- **`spl_token.json`** + `spl_token.meta.json` — Full SPL Token program IDL (shank origin, 34 extensions, ATA program, associated types, errors)
- **`token_2022.json`** + `token_2022.meta.json` — Full Token-2022 program IDL (js@v0.9.0, 35 extensions including confidential transfers, metadata pointer, token groups, pausable config, scaled UI amounts)
- **`system.json`** + `system.meta.json` — Full System Program IDL (js@v0.12.0, 13 instructions, Nonce account types, 9 error codes)

Each fixture includes a `.meta.json` provenance file recording the source repository, git commit, tag, file path, and SHA-256 hash for traceability.

These fixtures expand the renderer's acceptance test surface from a single SPL Token fixture to three real-world Solana programs covering diverse IDL features: nested enum variants with size-prefixed structs, zeroable option types, map types with prefixed counts, multiple additional programs, PDA definitions with seed derivation, and error code catalogs. The expanded coverage catches rendering edge cases that simpler IDLs do not exercise.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b)

#### Make codama-renderers-dart production-ready for real Solana program IDLs.

- Pin upstream SPL Token Codama JSON as acceptance fixture with provenance metadata
- Fix nullable codec type inference by emitting explicit type parameters
- Fix double-`??` on nullable optional instruction parameters
- Fix local variable shadowing in instruction builders and PDA helpers
- Add SPL Token acceptance test with dart analyze gate (28→0 errors)
- Add JS-vs-Dart structural parity tests for the SPL Token fixture
- Expose surfpool in devenv shell for validator-backed testing

_Owner:_ Ifiok Jr. · _Introduced in:_ [`c02af42`](https://github.com/openbudgetfun/solana_kit/commit/c02af42fc361fe016f54cfdfe0ad9b6ce2d1c13e) · _Last updated in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)

#### Add Codecov patch coverage and package-level coverage flags for Dart and renderer packages.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`30e1d19`](https://github.com/openbudgetfun/solana_kit/commit/30e1d192192800481fbdc6afa57dc1a1fd255986) · _Last updated in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)
