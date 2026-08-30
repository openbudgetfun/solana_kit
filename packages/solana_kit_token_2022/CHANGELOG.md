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

## solana_kit_token_2022 [0.5.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_token_2022/v0.5.2) (2026-08-12)

### 🚀 Feature

#### Token-2022: regenerate from js@v0.12.0

Regenerates the Token-2022 generated code from upstream IDL `js@v0.12.0` (was `js@v0.9.0`). Adds 9 new instructions:

- `configureConfidentialTransferAccountWithRegistry`
- `initializeConfidentialMintBurn`
- `rotateSupplyElgamalPubkey`
- `updateConfidentialMintBurnDecryptableSupply`
- `confidentialMint`
- `confidentialBurn`
- `applyConfidentialPendingBurn`
- `permissionedConfidentialBurn`
- `batch`

Updates existing instructions with changed account lists and arguments (auditor ciphertext args on confidential transfers, removed `record` accounts, `syncNative` rent account, `withdrawExcessLamports` account renames, `initializeConfidentialTransferFee` pubkey type change).

Adds `confidentialMintBurn` and `permissionedBurn` to the `ExtensionType` enum.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #195](https://github.com/openbudgetfun/solana_kit/pull/195)

### 📖 Documentation

#### Centralize package version documentation

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #188](https://github.com/openbudgetfun/solana_kit/pull/188)

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

### 🔖 None

#### Format workflow lint follow-up files

Apply formatting-only changes discovered while adding the GitHub Actions workflow lint gate.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #185](https://github.com/openbudgetfun/solana_kit/pull/185)

## solana_kit_token_2022 [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_token_2022/v0.7.0) (2026-08-18)

### 💥 Breaking Change

#### Regenerated program packages from upstream v7 IDLs

Regenerated all 8 generated program packages from their latest upstream Codama IDLs:

- solana_kit_system: js@v0.12.2 → v0.13.0
- solana_kit_token: js@v0.14.0 → v0.15.0
- solana_kit_token_2022: js@v0.12.0 → v0.14.1
- solana_kit_address_lookup_table: js@v0.12.1 → v0.13.0
- solana_kit_memo: js@v0.11.2 → v0.12.0
- solana_kit_compute_budget: js@v0.16.0 → v0.17.0
- solana_kit_stake: js@v0.7.2 → v0.8.0; applied the upstream Stake Codama preprocessing before rendering so generated defined-type imports resolve to Dart files
- solana_kit_loader: loader-v3 js@v0.4.0 → v0.5.0; migrated planning helpers to the generated v0.5 API and retained the handwritten Loader v3 account codecs and Loader v4 client surface

Generated using `node scripts/generate_program_packages.mjs` — a new generator script that runs the Codama renderer against upstream IDLs.

```dart
// Generated clients now match newer upstream IDLs, e.g. the system program:
final instruction = getCreateAccountInstruction(
  payer: payer.address,
  newAccount: newAccount.address,
  lamports: lamports,
  space: space,
  owner: owner,
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #204](https://github.com/openbudgetfun/solana_kit/pull/204)

## solana_kit_token_2022 [0.7.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_token_2022/v0.7.1) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_token_2022` was updated to 0.7.1.

## solana_kit_token_2022 [0.8.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_token_2022/v0.8.0) (2026-08-30)

### 🐛 Fixed

#### Refresh upstream reference pins for solana-program/* and mpl-bubblegum

- Tracks the latest upstream references in `config/reference-repos.json`: `solana-program/system` `js@v0.14.0` (was `js@v0.13.0`), `solana-program/token` `js@v0.16.0` (was `js@v0.15.0`), `solana-program/token-2022` `js@v0.16.0` (was `js@v0.14.1`), `solana-program/address-lookup-table` `js@v0.14.0` (was `js@v0.13.0`), `solana-program/memo` `js@v0.13.0` (was `js@v0.12.0`), `solana-program/compute-budget` `js@v0.18.0` (was `js@v0.17.0`), `solana-program/stake` `js@v0.9.0` (was `js@v0.8.0`), `solana-program/loader-v3` `js@v0.6.0` (was `js@v0.5.0`), `solana-program/loader-v4` commit `4f62fb2e` (was commit `1d6335be`), and `mpl-bubblegum` commit `6a6a77e3` (was commit `68e4bc20`).
- All of the `js` releases are `@solana/kit` ^7 → ^8 dependency bumps with no instructions, accounts, types, or wire-format changes; the IDL additions are Codama display metadata, which the Dart renderer does not render. Regenerating every affected client from the old and new pins produced byte-identical Dart output, so the generated clients are unchanged. The `mpl-bubblegum` new commit only re-exports the JS `mintV2` helpers and the `loader-v4` new commit only bumps its JS client to `@solana/kit` v8; both IDLs are unchanged. The `token-2022` pin supersedes the stale PR #222 (`js@v0.15.0`).
- `solana-program/stake` restructured its IDL to the Codama v1.8.0 format (program metadata block, `lockupParams` argument links renamed from `lockupArgs`, IDL program node renamed from `solanaStakeInterface` to `stake`). `scripts/generate_program_packages.mjs` now maps both argument link names and keeps the `solanaStakeInterface` renderer-facing program name, so the generated APIs (flattened `setLockup`/`setLockupChecked`/`authorizeWithSeed` argument fields, `SolanaStakeInterface` identifiers) stay stable. No generated Dart code changed.
- Package READMEs now cite the refreshed upstream versions they mirror.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #226](https://github.com/openbudgetfun/solana_kit/pull/226) · _Related issues:_ [#222](https://github.com/openbudgetfun/solana_kit/issues/222), [#225](https://github.com/openbudgetfun/solana_kit/issues/225)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)
