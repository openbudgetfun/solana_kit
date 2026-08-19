# Changelog

## solana_kit_loader [0.1.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_loader/v0.1.0) (2026-06-01)

### 💥 Breaking Change

#### Add Loader program package

Add a new loader package with BPF Loader v3 (Upgradeable) and Loader v4 program addresses, instruction builders, account header codecs, and deployment/upgrade instruction plan helpers.

```dart
import 'package:solana_kit_loader/solana_kit_loader.dart';

final instruction = getUpgradeInstruction(
  programDataAddress: programDataAddress,
  programAddress: programAddress,
  authority: authorityAddress,
  buffer: bufferAddress,
);
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`34c93b9`](https://github.com/openbudgetfun/solana_kit/commit/34c93b9b787dec4f04e0b44be560924332501100) · _Last updated in:_ [`2a9ae80`](https://github.com/openbudgetfun/solana_kit/commit/2a9ae8015344d2d0a55eefa55d26c25ab862b24d)

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

## solana_kit_loader [0.1.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_loader/v0.1.1) (2026-08-12)

### 🐛 Fixed

#### Bump program reference pins to latest upstream tags

Updates `config/reference-repos.json` and docs to track the latest upstream tags for program packages whose IDLs are unchanged or tooling-only:

- Token: `js@v0.13.0` → `js@v0.14.0`
- Address Lookup Table: `js@v0.11.0` → `js@v0.12.1`
- Memo: `js@v0.11.1` → `js@v0.11.2`
- Compute Budget: `js@v0.15.0` → `js@v0.16.0`
- Stake: `js@v0.6.1` → `js@v0.7.2`
- Loader v3: `js@v0.3.0` → `js@v0.4.0`

No generated Dart API changes for these packages — IDL comparison confirmed semantic equivalence. Updates are reference pin and documentation only.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #195](https://github.com/openbudgetfun/solana_kit/pull/195)

### 📖 Documentation

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## solana_kit_loader [0.3.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_loader/v0.3.0) (2026-08-18)

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

## solana_kit_loader [0.3.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_loader/v0.3.1) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_loader` was updated to 0.3.1.

## 0.0.0

Placeholder publication.
