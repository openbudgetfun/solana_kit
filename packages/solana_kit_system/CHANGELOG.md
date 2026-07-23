# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_system [0.3.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.3.2) (2026-05-30)

### 🚀 Feature

#### Port System Program from upstream Codama IDL

##### codama-renderers-dart

- Fix instruction builder `programAddress` param collision when an instruction's data also has a `programAddress` field (e.g., System `Assign`, `CreateAccount`). The instruction-level program address is now named `instructionProgramAddress` when a collision exists.
- Fix BigInt-width size prefix types (u64/u128) in `sizePrefixTypeNode` by substituting u32 encoder/decoder, which satisfies the Dart `Encoder<num>` constraint.

##### solana_kit_system

- Replace the handwritten `CreateAccount` helper with a fully generated client from `solana-program/system` Codama IDL (`js@v0.12.0`, commit `95897f3`).
- Includes all 13 System Program instructions, Nonce account type, NonceVersion/NonceState enums, 9 error codes, and program address constant.

##### solana_kit_token

- Update `getCreateMintInstructionPlan` to use the renamed `instructionProgramAddress` parameter from the regenerated system instruction.

##### solana_kit

- Re-export `solana_kit_system` with `systemProgramAddress` hidden to avoid conflict with `solana_kit_transaction_messages`.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`1eaf898`](https://github.com/openbudgetfun/solana_kit/commit/1eaf898cd0598744731152e8841dc632fc2e69f9) · _Last updated in:_ [`5bccc42`](https://github.com/openbudgetfun/solana_kit/commit/5bccc42120e7bc038fc507719727500364a43bd9)

#### Detached from main group

This package is now released independently rather than as part of the main solana_kit group. The System Program client is a standalone program package that does not depend on the core solana_kit release cycle, so an independent release track is more appropriate.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add generated-code test coverage for token

Add comprehensive generated-code test coverage for…

Add comprehensive generated-code test coverage for solana_kit_token (instructions, accounts, types, PDAs) and solana_kit_system (codec round-trips, parse round-trip, program constants).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`d930a56`](https://github.com/openbudgetfun/solana_kit/commit/d930a56035d5e4a34121be2a4d9ffcd30c0ad592) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

## solana_kit_system [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.4.0) (2026-06-01)

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

## solana_kit_system [0.4.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.4.1) (2026-06-03)

### 🚀 Feature

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

## solana_kit_system [0.4.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.4.2) (2026-07-23)

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
