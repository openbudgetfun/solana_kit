# Changelog

All notable changes to this package will be documented in this file.

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

#### Implement RPC spec package ported from `@solana/rpc-spec`.

**solana_kit_rpc_spec** (23 tests):

- `JsonRpcApi` with configurable request/response transformers creating `RpcPlan` objects
- `RpcPlan<T>` describing how to execute an RPC request with lazy execution
- `RpcTransport` typedef for pluggable transport layer
- `Rpc` client that wraps API + transport, returning `PendingRpcRequest` objects
- `PendingRpcRequest<T>` with `send()` method for deferred execution
- `isJsonRpcPayload` type guard for JSON-RPC 2.0 payload validation
- `RpcApi` abstract class with `JsonRpcApiAdapter` and `MapRpcApi` implementations
