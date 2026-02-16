---
solana_kit_rpc_subscriptions_channel_websocket: minor
---

Implement RPC subscriptions WebSocket channel package ported from `@solana/rpc-subscriptions-channel-websocket`.

**solana_kit_rpc_subscriptions_channel_websocket** (23 tests):

- `createWebSocketChannel` factory for creating WebSocket RPC subscription channels
- `RpcSubscriptionsChannel` interface extending `DataPublisher` with `send()` method
- `AbortSignal` / `AbortController` for clean channel shutdown
- `WebSocketChannelConfig` with URL, sendBufferHighWatermark, and optional abort signal
- Message forwarding via DataPublisher `'message'` channel
- Error publishing on abnormal WebSocket closure (non-1000 codes)
- Integration tests using real `HttpServer` with `WebSocketTransformer`
