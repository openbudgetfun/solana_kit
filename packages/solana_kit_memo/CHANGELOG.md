# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_memo [0.1.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_memo/v0.1.0) (2026-06-01)

### 💥 Breaking Change

#### Add Memo program package

Added `solana_kit_memo` with generated AddMemo codecs, current and legacy program addresses, ergonomic memo instruction helper, documentation, and tests.

```dart
import 'package:solana_kit_memo/solana_kit_memo.dart';

final instruction = getAddMemoInstruction(memo: 'Hello Solana!');
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`02374ef`](https://github.com/openbudgetfun/solana_kit/commit/02374ef6f5daf316b1d9b404f9a1e2a48b7983f6) · _Last updated in:_ [`2a9ae80`](https://github.com/openbudgetfun/solana_kit/commit/2a9ae8015344d2d0a55eefa55d26c25ab862b24d)

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

## solana_kit_memo [0.1.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_memo/v0.1.1) (2026-06-03)

### 🐛 Fixed

#### Update upstream program references

Update generated Solana program packages to the latest checked upstream refs:

```text
solana_kit_system: solana-program/system js@v0.12.2
solana_kit_stake: solana-program/stake js@v0.6.1
solana_kit_memo: solana-program/memo js@v0.11.1
```

`solana_kit_system` adds the `CreateAccountAllowPrefund` instruction helpers.
`solana_kit_stake` includes the authority seed `u64` size-prefix fix and updated stake delegation layout.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #182](https://github.com/openbudgetfun/solana_kit/pull/182)

## 0.0.0

Placeholder publication.
