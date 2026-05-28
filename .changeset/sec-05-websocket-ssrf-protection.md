---
"solana_kit_rpc_subscriptions_channel_websocket": patch
---

# SEC-05: Add SSRF protection for WebSocket URLs.

- Block connections to private/internal hosts by default (localhost, 10.x, 172.16-31.x, 192.168.x, 169.254.x, fc/fd::)
- Added `allowPrivateHosts` option to `WebSocketChannelConfig` for local development
- 5 new SSRF protection tests
