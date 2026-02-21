# Changelog

All notable changes to this package will be documented in this file.

## 0.0.2 (2026-02-21)

### Features

#### Implement RPC client package ported from `@solana/rpc`.

**solana_kit_rpc** (125 tests):

- `createSolanaRpc` and `createSolanaRpcFromTransport` factory functions combining API + transport + transformers
- `createDefaultRpcTransport` with `solana-client: dart/0.0.1` header and request coalescing
- Request coalescing: deduplicates identical JSON-RPC requests within the same microtask
- Deduplication key generation using `fastStableStringify` for deterministic request hashing
- Integer overflow error creation with human-readable ordinal argument labels
- Default RPC config: `confirmed` commitment, integer overflow handler

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
