---
"solana_kit_rpc_subscriptions": minor
"solana_kit_rpc_subscriptions_channel_websocket": minor
"solana_kit_subscribable": minor
"solana_kit_test_matchers": test
"solana_kit_transaction_confirmation": minor
---

Refactor subscription internals toward stream-native Dart APIs while keeping the existing `DataPublisher` and `AbortSignal` compatibility APIs available as deprecated APIs.

Added stream-native helpers for channel streams, demultiplexing, reactive stores, and data/error stream composition, and migrated internal subscription consumers to use Dart `Stream`/`StreamSubscription` flows where possible.
