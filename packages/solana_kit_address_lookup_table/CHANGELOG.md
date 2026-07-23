# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_address_lookup_table [0.1.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_address_lookup_table/v0.1.0) (2026-06-01)

### 💥 Breaking Change

#### Add Address Lookup Table program package

Add `solana_kit_address_lookup_table` package with the full generated+helpers Address Lookup Table program client. Includes all five instructions (`CreateLookupTable`, `FreezeLookupTable`, `ExtendLookupTable`, `DeactivateLookupTable`, `CloseLookupTable`), the `AddressLookupTable` account decoder/fetch helpers, PDA derivation, create-with-PDA convenience builder, lookup table size constants, byte-delta metadata, codec round-trip tests, instruction identification, and parsed instruction types.

```dart
import 'package:solana_kit_address_lookup_table/solana_kit_address_lookup_table.dart';

final instruction = getCreateLookupTableInstruction(
  authority: authorityAddress,
  payer: payerAddress,
);
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`53ace22`](https://github.com/openbudgetfun/solana_kit/commit/53ace22f3a4cb5fa7e41b76675a406275bd6fc2e) · _Last updated in:_ [`2a9ae80`](https://github.com/openbudgetfun/solana_kit/commit/2a9ae8015344d2d0a55eefa55d26c25ab862b24d)

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

#### Trim Address Lookup Table changelog

Replace the accidentally copied workspace-wide changelog with the package-specific Address Lookup Table entry.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`d891bbc`](https://github.com/openbudgetfun/solana_kit/commit/d891bbcccf91f9582d13dc7984cef180fa682ba3)

## solana_kit_address_lookup_table [0.1.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_address_lookup_table/v0.1.1) (2026-07-23)

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

## 0.0.0

Placeholder publication.
