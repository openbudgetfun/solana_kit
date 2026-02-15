---
solana_kit_rpc_types: minor
---

Implement RPC types package ported from `@solana/rpc-types`.

**solana_kit_rpc_types** (85 tests):

- `Blockhash` extension type with validation, codec (32-byte base58), and comparator
- `Lamports` extension type (0 to 2^64-1) with generic encoder/decoder/codec wrappers
- `UnixTimestamp` extension type (i64 range) with validation
- `StringifiedBigInt` and `StringifiedNumber` extension types with validation
- `Commitment` enum (processed, confirmed, finalized) with comparator
- `MicroLamports`, `SignedLamports`, `Slot`, `Epoch` type aliases
- Encoded data types: `Base58EncodedBytes`, `Base64EncodedBytes`, data response records
- Account info types: `AccountInfoBase` and encoding-specific variants
- `TokenAmount`, `TokenBalance` for SPL token data
- `TransactionError` and `InstructionError` sealed class hierarchies
- `TransactionVersion`, `Reward`, `TransactionStatus` types
- Cluster URL types: `MainnetUrl`, `DevnetUrl`, `TestnetUrl`
- `SolanaRpcResponse<T>` wrapper with slot context
- Account filter types: `DataSlice`, memcmp and datasize filters
