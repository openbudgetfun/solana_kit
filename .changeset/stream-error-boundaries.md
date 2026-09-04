---
"solana_kit_subscribable": patch
---

# Propagate stream errors and cancellation

Contain native source errors and malformed notification type/transformer failures within subscription streams, where consumer error handlers can receive them. Release reactive connection listeners when caller cancellation fires, and avoid opening a connection after a loading subscriber resets or disposes its store.

Fix reactive stream bridge cancellation while awaiting a quiet store, unsubscribe after predicate failures, and preserve latest-value delivery and error precedence while consumers are paused.
