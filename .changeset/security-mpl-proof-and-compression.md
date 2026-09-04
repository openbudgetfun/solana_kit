---
"solana_kit_mpl_bubblegum": patch
"solana_kit_spl_account_compression": patch
---

# Validate Merkle proofs and correct compressed NFT data

Reject Merkle proof index aliases and hash nodes that are not 32 bytes. Preserve DAS owner and delegate addresses, use the compression leaf ID as the nonce, and convert the proof node index to its leaf index.

Calculate concurrent Merkle tree account sizes using the on-chain change-log, path, and canopy layouts. An omitted canopy depth now allocates no canopy, matching the upstream SDK.
