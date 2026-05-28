---
solana_kit_spl_account_compression: major
---

# Add SPL Account Compression package

New package providing Solana Program Library (SPL) Account Compression utilities for the Solana Kit Dart SDK:

- **Merkle tree size calculator** (`getConcurrentMerkleTreeAccountSize`) for computing on-chain account sizes
- **Valid depth/buffer size pairs** (`validDepthSizePairs`, `isValidDepthSizePair`)
- **Program addresses** (`splAccountCompressionProgramAddress`, `noopProgramAddress`)
- **PDA derivation** for merkle tree accounts (`findMerkleTreePda`)
