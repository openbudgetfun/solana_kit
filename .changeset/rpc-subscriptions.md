---
solana_kit_rpc_subscriptions: minor
---

Implement RPC subscriptions composition package ported from `@solana/rpc-subscriptions`.

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
