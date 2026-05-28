---
solana_kit_mpl_bubblegum: major
---

# Add Metaplex Bubblegum (compressed NFT) package

New package providing mpl-bubblegum compressed NFT utilities for the Solana Kit Dart SDK:

- **Keccak-256 hashing** (`bubblegumHash`, `hashLeafV1`, `hashLeafV2`) matching on-chain program logic
- **Merkle tree** construction and proof verification (`MerkleTree`, `computeEmptyNode`)
- **PDA derivation** (`findTreeAuthorityPda`, `findLeafAssetIdPda`, `findBubblegumSignerPda`)
- **Leaf schema V2 flags** (`LeafSchemaV2Flags`) for parsing compressed NFT leaf data
- **Transfer eligibility** (`canTransfer`) for checking frozen/non-transferable status
- **Program addresses** (`mplBubblegumProgramAddress`, `tokenMetadataProgramAddress`)

> **Note:** Codama-generated instruction builders and account decoders are not yet available
> and will be added in a future release once the IDL-to-Dart pipeline supports these programs.
