---
solana_kit_rpc_transformers: minor
---

Implement RPC transformers package ported from `@solana/rpc-transformers`.

**solana_kit_rpc_transformers** (524 tests):

- Request transformers: BigInt downcast, integer overflow detection, default commitment injection
- Response transformers: BigInt upcast, JSON-RPC error throwing with Solana error unwrapping, result extraction
- Tree traversal utilities with key path wildcards for deep object walking
- Default commitment handling for 39 RPC methods with per-method config position mapping
- Preflight error unwrapping from `-32002` JSON-RPC errors
- Composable transformer pipelines via `getDefaultRequestTransformerForSolanaRpc` and `getDefaultResponseTransformerForSolanaRpc`
