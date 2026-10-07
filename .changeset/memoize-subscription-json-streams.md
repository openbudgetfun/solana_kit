---
"solana_kit_rpc_subscriptions": patch
---

# Parse each WebSocket notification once per channel

The JSON and BigInt-JSON channel wrappers no longer build a fresh mapped stream on every `streams` access. Each subscription on a shared channel previously created its own parse pipeline, so a pooled channel serving N subscriptions JSON-parsed every inbound message N times — at the default pool capacity of 100 subscriptions per channel that was a 100× CPU multiplier on the hottest subscription path. All subscriptions on a channel now share one decoded stream, and each message is parsed exactly once. Delivery semantics are unchanged: the underlying streams are broadcast, so every subscription still receives every notification.
