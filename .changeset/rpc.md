---
solana_kit_rpc: minor
---

Implement RPC client package ported from `@solana/rpc`.

**solana_kit_rpc** (125 tests):

- `createSolanaRpc` and `createSolanaRpcFromTransport` factory functions combining API + transport + transformers
- `createDefaultRpcTransport` with `solana-client: dart/0.0.1` header and request coalescing
- Request coalescing: deduplicates identical JSON-RPC requests within the same microtask
- Deduplication key generation using `fastStableStringify` for deterministic request hashing
- Integer overflow error creation with human-readable ordinal argument labels
- Default RPC config: `confirmed` commitment, integer overflow handler
