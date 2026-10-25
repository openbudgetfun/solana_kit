---
"solana_kit_rpc_subscriptions": minor
"solana_kit_rpc_subscriptions_channel_websocket": minor
---

# Remove the sendBufferHighWatermark no-op option

`WebSocketChannelConfig.sendBufferHighWatermark` and the matching `DefaultRpcSubscriptionsChannelConfig.sendBufferHighWatermark` were documented as send-buffer high watermarks that queue outbound messages client-side once exceeded. No such behavior existed: `send` always handed each message straight to the WebSocket, because `web_socket_channel` exposes no buffered-amount state or drain signal to enforce it against. Both options are removed; outbound traffic is limited to small client-generated subscribe and unsubscribe frames, so no bound is needed. Code that set the option should simply drop the argument.
