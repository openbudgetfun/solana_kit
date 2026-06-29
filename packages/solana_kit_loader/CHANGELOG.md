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

## solana_kit_loader [0.1.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_loader/v0.1.1) (2026-06-29)

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

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a4c5169`](https://github.com/openbudgetfun/solana_kit/commit/a4c5169c0e891c211f39958219268ae9ad8b9934)

## 0.0.0

Placeholder publication.
