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

## solana_kit_token_2022 [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_token_2022/v0.5.0) (2026-06-01)

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

## solana_kit_token_2022 [0.5.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_token_2022/v0.5.1) (2026-06-03)

### Changed

- No package-specific changes were recorded; `solana_kit_token_2022` was updated to 0.5.1.

## solana_kit_token_2022 [0.5.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_token_2022/v0.5.2) (2026-06-29)

### 🚀 Feature

#### Token-2022: regenerate from js@v0.12.0

Regenerates the Token-2022 generated code from upstream IDL `js@v0.12.0`
(was `js@v0.9.0`). Adds 9 new instructions:

- `configureConfidentialTransferAccountWithRegistry`
- `initializeConfidentialMintBurn`
- `rotateSupplyElgamalPubkey`
- `updateConfidentialMintBurnDecryptableSupply`
- `confidentialMint`
- `confidentialBurn`
- `applyConfidentialPendingBurn`
- `permissionedConfidentialBurn`
- `batch`

Updates existing instructions with changed account lists and arguments
(auditor ciphertext args on confidential transfers, removed `record`
accounts, `syncNative` rent account, `withdrawExcessLamports` account
renames, `initializeConfidentialTransferFee` pubkey type change).

Adds `confidentialMintBurn` and `permissionedBurn` to the `ExtensionType`
enum.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`89b3457`](https://github.com/openbudgetfun/solana_kit/commit/89b3457135968f975f0a002a1ef1b33072de6320)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`914f224`](https://github.com/openbudgetfun/solana_kit/commit/914f224a81e16a40c21554cd6766845ead05a6e9)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a4c5169`](https://github.com/openbudgetfun/solana_kit/commit/a4c5169c0e891c211f39958219268ae9ad8b9934)

### 🔖 None

#### Format workflow lint follow-up files

Apply formatting-only changes discovered while adding the GitHub Actions workflow lint gate.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`e611148`](https://github.com/openbudgetfun/solana_kit/commit/e611148d1af6884297196096ca5e03f784496ebe)
