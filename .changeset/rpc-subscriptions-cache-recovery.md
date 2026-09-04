---
"solana_kit_rpc_subscriptions": patch
---

# Recover failed RPC subscription cache entries

Recover subscription acquisition after transport failures, prevent repeated errors from evicting a replacement subscription, and reuse channel capacity released while the subscription pool was full.

Handle native channel stream errors in subscription coalescing, channel pooling, and keepalive pinging so failed connections are cleaned up without uncaught asynchronous errors.
