---
solana_kit_rpc_api: minor
---

Implement RPC API package ported from `@solana/rpc-api`.

**solana_kit_rpc_api** (75 tests):

- Config and params classes for all 52 Solana RPC methods (getAccountInfo, getBalance, getBlock, sendTransaction, simulateTransaction, etc.)
- `solanaRpcMethodsForAllClusters` (51 methods) and `solanaRpcMethodsForTestClusters` (52 methods, includes requestAirdrop)
- `getAllowedNumericKeypaths()` for response transformer numeric value whitelisting
- Cluster-variant helpers: `isSolanaRpcMethodForMainnet`, `isSolanaRpcMethodForTestClusters`
- Per-method `toJson()` serialization and params builder functions
