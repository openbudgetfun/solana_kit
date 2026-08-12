# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_mpl_bubblegum [0.2.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mpl_bubblegum/v0.2.0) (2026-05-30)

### 💥 Breaking Change

#### Add Metaplex Bubblegum (compressed NFT) package

New package providing mpl-bubblegum compressed NFT utilities for the Solana Kit Dart SDK:

- **Keccak-256 hashing** (`bubblegumHash`, `hashLeafV1`, `hashLeafV2`) matching on-chain program logic
- **Merkle tree** construction and proof verification (`MerkleTree`, `computeEmptyNode`)
- **PDA derivation** (`findTreeAuthorityPda`, `findLeafAssetIdPda`, `findBubblegumSignerPda`)
- **Leaf schema V2 flags** (`LeafSchemaV2Flags`) for parsing compressed NFT leaf data
- **Transfer eligibility** (`canTransfer`) for checking frozen/non-transferable status
- **Program addresses** (`mplBubblegumProgramAddress`, `tokenMetadataProgramAddress`)

> **Note:** Codama-generated instruction builders and account decoders are not yet available
> and will be added in a future release once the IDL-to-Dart pipeline supports these programs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🚀 Feature

#### Add composite helpers, DAS client, and V2 support

- Add getMintV2InstructionPlan() for V2 minting
- Add getMintToCollectionV1InstructionPlan() for collection minting
- Add getCreateTreeV2InstructionPlan() for V2 tree creation
- Add HeliusDasClient for DAS API integration
- Add MetadataArgsV2 encoder
- Add README documentation

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ff2ad0e`](https://github.com/openbudgetfun/solana_kit/commit/ff2ad0e5d055a5aee984b3d0bf6c381b8c580e58) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add on-chain integration tests and compressed NFT example

Add integration tests for compressed NFT operations and a Dart CLI example.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`99a29b3`](https://github.com/openbudgetfun/solana_kit/commit/99a29b34f41a35e5e3a20601da2f04e62da42ca7) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Fix barrel export ambiguity

Fix ambiguous_export, directives_ordering, and eol_at_end_of_file lint issues in the barrel file.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`d5765af`](https://github.com/openbudgetfun/solana_kit/commit/d5765af199ad10b93ff613abe46a942b70205ba1)

#### Refactor to idiomatic Dart patterns

- Add `concatBytes()` and `concatAll()` utilities for efficient byte array concatenation
- Replace `Uint8List.fromList([...a, ...b])` with `concatBytes(a, b)` in merkle tree and hash functions
- Add `@immutable` annotation to internal `_MerkleNode` class
- Use `const` constructor for immutable classes
- Add `zeroBytes32()`, `bytes32FromHex()`, `bytes32ToHex()` utilities for 32-byte arrays

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9dc6bc6`](https://github.com/openbudgetfun/solana_kit/commit/9dc6bc6bf16d1e883c2ebb1e806c1a710468dfd3) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

## solana_kit_mpl_bubblegum [0.3.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mpl_bubblegum/v0.3.0) (2026-06-01)

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

### 🧪 Testing

#### Optimize compressed NFT integration test polling

Replaced a fixed local airdrop delay with short balance polling so integration tests complete faster while preserving the same assertion.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ead9932`](https://github.com/openbudgetfun/solana_kit/commit/ead9932533e0ebd1dabf7e8fde813b1d6d372208)
