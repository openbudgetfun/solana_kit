# Changelog

All notable changes to this package will be documented in this file.

## 0.1.0 (2026-02-21)

### Notes

- First 0.1.0 release of this package.

## 0.0.2 (2026-02-21)

### Features

#### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

#### Implement RPC types package ported from `@solana/rpc-types`.

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
