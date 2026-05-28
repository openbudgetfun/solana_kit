# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_mpl_bubblegum [0.2.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_mpl_bubblegum/v0.2.0) (2026-05-28)

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

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a)

### 🚀 Feature

#### Add composite helpers, DAS client, and V2 support

- Add getMintV2InstructionPlan() for V2 minting
- Add getMintToCollectionV1InstructionPlan() for collection minting
- Add getCreateTreeV2InstructionPlan() for V2 tree creation
- Add HeliusDasClient for DAS API integration
- Add MetadataArgsV2 encoder
- Add README documentation

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ff2ad0e`](https://github.com/openbudgetfun/solana_kit/commit/ff2ad0e5d055a5aee984b3d0bf6c381b8c580e58)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910)

#### Add on-chain integration tests and compressed NFT example

Add integration tests for compressed NFT operations and a Dart CLI example.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`99a29b3`](https://github.com/openbudgetfun/solana_kit/commit/99a29b34f41a35e5e3a20601da2f04e62da42ca7)

#### Refactor to idiomatic Dart patterns

- Add `concatBytes()` and `concatAll()` utilities for efficient byte array concatenation
- Replace `Uint8List.fromList([...a, ...b])` with `concatBytes(a, b)` in merkle tree and hash functions
- Add `@immutable` annotation to internal `_MerkleNode` class
- Use `const` constructor for immutable classes
- Add `zeroBytes32()`, `bytes32FromHex()`, `bytes32ToHex()` utilities for 32-byte arrays

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9dc6bc6`](https://github.com/openbudgetfun/solana_kit/commit/9dc6bc6bf16d1e883c2ebb1e806c1a710468dfd3)
