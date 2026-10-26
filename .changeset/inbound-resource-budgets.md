---
"solana_kit_rpc_spec_types": patch
"solana_kit_rpc_transport_http": patch
"solana_kit_rpc_subscriptions_channel_websocket": patch
"solana_kit_mobile_wallet_adapter_protocol": patch
"solana_kit_mobile_wallet_adapter": patch
"solana_kit_rpc": patch
"solana_kit_rpc_subscriptions": patch
---

# Bound untrusted inbound transport payloads

Add configurable inbound limits of 16 MiB, 64 JSON container levels, and one million JSON tokens. HTTP responses stop streaming on overflow, including when Content-Length is absent or understated, and custom decoders receive only bounded JSON. WebSocket channels close with application code 4009 on message or paused-listener queue overflow; queues default to 128 messages and 16 MiB per listener. Local and remote wallet sessions bound binary and base64 frames before copying or decrypting, validate decrypted JSON before parsing, and release session keys when a rejected frame closes the session.
