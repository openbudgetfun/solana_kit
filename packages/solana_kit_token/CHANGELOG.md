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

## solana_kit_token [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_token/v0.5.0) (2026-06-01)

### 💥 Breaking Change

#### Raise minimum Dart SDK to 3.12

Raise the minimum supported Dart SDK constraint to `^3.12.0` across public Dart packages.

This is a breaking change because consumers must use Dart 3.12 or newer. Flutter consumers must use a Flutter SDK that bundles Dart 3.12 or newer.

```yaml
environment:
  sdk: ^3.12.0
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`32d5d36`](https://github.com/openbudgetfun/solana_kit/commit/32d5d367abb7615fea5ee341f03d17c2bc0d66dd)

### 🐛 Fixed

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

## solana_kit_token [0.5.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_token/v0.5.1) (2026-06-03)

### Changed

- No package-specific changes were recorded; `solana_kit_token` was updated to 0.5.1.

## solana_kit_token [0.5.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_token/v0.5.2) (2026-06-29)

### 🐛 Fixed

#### Bump program reference pins to latest upstream tags

Updates `config/reference-repos.json` and docs to track the latest
upstream tags for program packages whose IDLs are unchanged or
tooling-only:

- Token: `js@v0.13.0` → `js@v0.14.0`
- Address Lookup Table: `js@v0.11.0` → `js@v0.12.1`
- Memo: `js@v0.11.1` → `js@v0.11.2`
- Compute Budget: `js@v0.15.0` → `js@v0.16.0`
- Stake: `js@v0.6.1` → `js@v0.7.2`
- Loader v3: `js@v0.3.0` → `js@v0.4.0`

No generated Dart API changes for these packages — IDL comparison
confirmed semantic equivalence. Updates are reference pin and
documentation only.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`89b3457`](https://github.com/openbudgetfun/solana_kit/commit/89b3457135968f975f0a002a1ef1b33072de6320)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`914f224`](https://github.com/openbudgetfun/solana_kit/commit/914f224a81e16a40c21554cd6766845ead05a6e9)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a4c5169`](https://github.com/openbudgetfun/solana_kit/commit/a4c5169c0e891c211f39958219268ae9ad8b9934)
