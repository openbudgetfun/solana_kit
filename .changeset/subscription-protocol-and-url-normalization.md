---
"solana_kit_rpc_subscriptions": patch
"solana_kit_rpc_subscriptions_channel_websocket": patch
---

# Fix subscription protocol and URL validation

Execute the default Solana subscription JSON-RPC handshake, validate its server subscription ID, isolate notifications on pooled channels, and send unsubscribe requests during cancellation. Preserve notifications received during acquisition with a bounded initial buffer and route protocol, channel, and decoding failures to subscribers.

Normalize WebSocket destination literals before applying private-host protection, covering expanded and hexadecimal IPv4-mapped IPv6 forms and trailing DNS root dots without rejecting public hostnames that resemble IPv6 prefixes.

Reject cancelled WebSocket handshakes promptly, close late connections, reject sends after cancellation, and finish public streams when their channel ends.
