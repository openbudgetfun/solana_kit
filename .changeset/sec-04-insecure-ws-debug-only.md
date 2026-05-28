---
"solana_kit_rpc_subscriptions_channel_websocket": patch
---

# SEC-04: Restrict allowInsecureWs to debug mode only.

- In release/profile mode, `ws://` URLs are now always rejected regardless of the `allowInsecureWs` flag
- Prevents accidental use of insecure WebSocket connections in production
- Updated documentation to reflect the debug-only behavior
