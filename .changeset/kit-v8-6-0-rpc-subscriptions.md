---
"solana_kit_rpc_subscriptions": patch
---

# Make channel pool entry destruction idempotent

Ports #2121 from `@solana/rpc-subscriptions` v8.6.0: destroying a pool entry that is already gone now returns early. Previously, when the last subscriber of a channel that had already errored or failed to construct aborted, the destroy path could remove an unrelated, healthy channel that still had its own subscribers.
