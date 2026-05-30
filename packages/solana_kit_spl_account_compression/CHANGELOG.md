# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_spl_account_compression [0.2.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_spl_account_compression/v0.2.0) (2026-05-30)

### 💥 Breaking Change

#### Add SPL Account Compression package

New package providing Solana Program Library (SPL) Account Compression utilities for the Solana Kit Dart SDK:

- **Merkle tree size calculator** (`getConcurrentMerkleTreeAccountSize`) for computing on-chain account sizes
- **Valid depth/buffer size pairs** (`validDepthSizePairs`, `isValidDepthSizePair`)
- **Program addresses** (`splAccountCompressionProgramAddress`, `noopProgramAddress`)
- **PDA derivation** for merkle tree accounts (`findMerkleTreePda`)

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### No changes to spl_account_compression in this PR

This changeset is required to satisfy the changeset policy.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ff2ad0e`](https://github.com/openbudgetfun/solana_kit/commit/ff2ad0e5d055a5aee984b3d0bf6c381b8c580e58) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)
