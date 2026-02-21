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

#### Implement RPC transformers package ported from `@solana/rpc-transformers`.

**solana_kit_rpc_transformers** (524 tests):

- Request transformers: BigInt downcast, integer overflow detection, default commitment injection
- Response transformers: BigInt upcast, JSON-RPC error throwing with Solana error unwrapping, result extraction
- Tree traversal utilities with key path wildcards for deep object walking
- Default commitment handling for 39 RPC methods with per-method config position mapping
- Preflight error unwrapping from `-32002` JSON-RPC errors
- Composable transformer pipelines via `getDefaultRequestTransformerForSolanaRpc` and `getDefaultResponseTransformerForSolanaRpc`
