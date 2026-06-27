---
"solana_kit_rpc_types": major
---

# Remove deprecated base58 account info types

Removes the deprecated `AccountInfoWithBase58Bytes` and `AccountInfoWithBase58EncodedData` classes. The Solana RPC API now returns account data as base64 (or base64+zstd) instead of base58. Use `AccountInfoWithBase64EncodedData` instead.
