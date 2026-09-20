# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_config [0.1.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_config/v0.1.0) (2026-06-01)

### 💥 Breaking Change

#### Add Solana Config program client

Add the Solana Config program package with generated codecs, account decoder, Store instruction builder, and typed store helper.

```dart
import 'package:solana_kit_config/solana_kit_config.dart';

final instruction = getStoreConfigInstruction(
  configAccount: configAddress,
  keys: ConfigKeys(keys: [ConfigKey(pubkey: signer, isSigner: true)]),
  configData: Uint8List.fromList([1, 2, 3]),
);
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`7caff09`](https://github.com/openbudgetfun/solana_kit/commit/7caff094793e05d3aae4c720e93fb1d0233b0dcb) · _Last updated in:_ [`2a9ae80`](https://github.com/openbudgetfun/solana_kit/commit/2a9ae8015344d2d0a55eefa55d26c25ab862b24d)

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

## solana_kit_config [0.1.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_config/v0.1.1) (2026-08-12)

### 📖 Documentation

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## solana_kit_config [0.1.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_config/v0.1.2) (2026-08-18)

### 📖 Documentation

#### Reformat package docs

Docs have been reformatted to remove line wrapping.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #212](https://github.com/openbudgetfun/solana_kit/pull/212)

## solana_kit_config [0.1.3](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_config/v0.1.3) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_config` was updated to 0.1.3.

## solana_kit_config [0.2.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_config/v0.2.0) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_config` was updated to 0.2.0.

## solana_kit_config [0.2.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_config/v0.2.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_config` was updated to 0.2.1.

## solana_kit_config [0.2.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_config/v0.2.2) (2026-09-06)

### Changed

- No package-specific changes were recorded; `solana_kit_config` was updated to 0.2.2.

## solana_kit_config [0.2.3](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_config/v0.2.3) (2026-09-12)

### Fixes

- **Document program errors and the generated program-client contract.** Add library doc comments synchronized from shared MDT sections to thirteen packages: program error matching (`isProgramError` + `TransactionMessageInput`) and the generated program-client API shape are now documented inline in each library and in the errors docs page; six barrels that had no library doc comment gain one; three one-line library headers are expanded. No code changes. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #248](https://github.com/openbudgetfun/solana_kit/pull/248)

## solana_kit_config [0.3.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_config/v0.3.0) (2026-09-21)

### Breaking changes

#### Raise the Dart and Flutter baseline

The workspace now builds against Dart 3.13.3 and Flutter 3.47.4, and every package declares that floor instead of the previous Dart 3.12 range. Consumers on older SDKs can no longer resolve these packages, so this release is breaking even though no Dart API changed.

The Flutter floor rises from 3.44 to 3.47 for `solana_kit_mobile_wallet_adapter`, `solana_kit_mobile_wallet_adapter_protocol`, and `solana_kit_wallet_adapter`, matching the floor `solana_kit_wallet_ui` already required. `solana_kit_lints` ships the raised floor to consumers, so it carries the same breaking bump. Every other package raises only the Dart SDK floor.

Raising the language version also switches `dart format` to the tall style, so 83 files across library, test, script, and Codama-generated trees are reflowed. The renderer pipes generated output through `dart format`, so regenerating stays consistent.

Align your own SDK constraint with the workspace:

```yaml
environment:
  sdk: ^3.13.0
  # Omit for pure Dart packages; required for the Flutter packages above.
  flutter: ">=3.47.0"
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [5f5fe01](https://github.com/openbudgetfun/solana_kit/commit/5f5fe01f3e2220ccfee54cc26e82c3face26589d) · _Last updated in:_ [19932db](https://github.com/openbudgetfun/solana_kit/commit/19932dba1979f1190b7501947b87eb8a4d4cc8d5)

## 0.0.0

Placeholder publication.
