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

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #172](https://github.com/openbudgetfun/solana_kit/pull/172) · _Closed issues:_ [#137](https://github.com/openbudgetfun/solana_kit/issues/137)

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

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #177](https://github.com/openbudgetfun/solana_kit/pull/177) · _Related issues:_ [#134](https://github.com/openbudgetfun/solana_kit/issues/134)

## 0.0.0

Placeholder publication.
