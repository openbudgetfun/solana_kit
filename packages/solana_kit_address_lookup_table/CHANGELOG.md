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

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #149](https://github.com/openbudgetfun/solana_kit/pull/149) · _Closed issues:_ [#134](https://github.com/openbudgetfun/solana_kit/issues/134)

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

#### Trim Address Lookup Table changelog

Replace the accidentally copied workspace-wide changelog with the package-specific Address Lookup Table entry.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #174](https://github.com/openbudgetfun/solana_kit/pull/174)

## 0.0.0

Placeholder publication.
