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

#### Implement RPC subscriptions composition package ported from `@solana/rpc-subscriptions`.

**solana_kit_rpc_subscriptions** (144 tests):

- `createSolanaRpcSubscriptions` and `createSolanaRpcSubscriptionsUnstable` factory functions
- `createSolanaRpcSubscriptionsFromTransport` for custom transport usage
- `getRpcSubscriptionsTransportWithSubscriptionCoalescing` deduplicating identical subscriptions via fastStableStringify hashing
- `getRpcSubscriptionsChannelWithAutoping` periodic keep-alive ping messages with timer reset on activity
- `getChannelPoolingChannelCreator` channel reuse with maxSubscriptionsPerChannel limits and automatic cleanup
- `getRpcSubscriptionsChannelWithJsonSerialization` and `getRpcSubscriptionsChannelWithBigIntJsonSerialization`
- `createDefaultSolanaRpcSubscriptionsChannelCreator` composing JSON + autopinger + pooling
- `createSolanaJsonRpcIntegerOverflowError` with ordinal argument labels
- Default RPC subscription configuration with `confirmed` commitment
