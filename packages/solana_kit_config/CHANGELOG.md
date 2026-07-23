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

## solana_kit_config [0.1.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_config/v0.1.1) (2026-07-23)

### 📖 Documentation

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## 0.0.0

Placeholder publication.
