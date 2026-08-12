# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_compute_budget [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_compute_budget/v0.5.0) (2026-06-01)

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

### 🧪 Testing

#### Improve test coverage to 95%+ across all packages

Added 500+ tests covering equality/hashCode/toString, codec edge cases, error paths, and constructor variants. Removed dead code in fast_stable_stringify. Fixed concurrent modification bug in subscribable.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`48216f9`](https://github.com/openbudgetfun/solana_kit/commit/48216f9af0ff058d7db83994e5bdb3b9be95fdf8) · _Last updated in:_ [`b7f5419`](https://github.com/openbudgetfun/solana_kit/commit/b7f5419bbe792d4ba1731eba227088d8f74a3ebb)

## solana_kit_compute_budget [0.5.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_compute_budget/v0.5.1) (2026-06-03)

### 🚀 Feature

#### Add Compute Budget message helpers

Add transaction-message helper APIs for Compute Budget instructions, including introspection and update-or-append helpers for compute unit limits and prices.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #184](https://github.com/openbudgetfun/solana_kit/pull/184)

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

### 💥 Breaking Change

#### New package available

Compute Budget program client for the Solana Kit Dart SDK. Provides instruction builders for setting compute unit limits and priorities on Solana transactions.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🚀 Feature

#### Add compute budget package

Add solana_kit_compute_budget package with the full…

Add `solana_kit_compute_budget` package with the full generated+helpers Compute Budget program client. Includes all five instructions (RequestUnits, RequestHeapFrame, SetComputeUnitLimit, SetComputeUnitPrice, SetLoadedAccountsDataSizeLimit), codec round-trip tests, instruction identification, and parsed instruction types.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3a0e076`](https://github.com/openbudgetfun/solana_kit/commit/3a0e076245cbed19e5015a912edf3bb6fc7e0f0b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)
