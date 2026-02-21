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

#### Implement RPC subscriptions WebSocket channel package ported from `@solana/rpc-subscriptions-channel-websocket`.

**solana_kit_rpc_subscriptions_channel_websocket** (23 tests):

- `createWebSocketChannel` factory for creating WebSocket RPC subscription channels
- `RpcSubscriptionsChannel` interface extending `DataPublisher` with `send()` method
- `AbortSignal` / `AbortController` for clean channel shutdown
- `WebSocketChannelConfig` with URL, sendBufferHighWatermark, and optional abort signal
- Message forwarding via DataPublisher `'message'` channel
- Error publishing on abnormal WebSocket closure (non-1000 codes)
- Integration tests using real `HttpServer` with `WebSocketTransformer`

### Fixes

#### Enhance core SDK packages with additional functionality and tests.

- **Codecs core**: Enhanced `addCodecSizePrefix` with additional functionality
- **Codecs data structures**: Array codec improvements
- **Codecs numbers**: `shortU16` codec enhancements
- **Codecs strings**: UTF-8 codec improvements
- **Keys**: Key pair and signatures enhancements
- **RPC transport**: HTTP transport and WebSocket channel updates
- **Transactions**: Transaction codec enhancements
