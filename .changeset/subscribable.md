---
solana_kit_subscribable: minor
---

Implement subscribable package ported from `@solana/subscribable`.

**solana_kit_subscribable** (33 tests):

- `DataPublisher` interface with `on(channelName, subscriber)` returning unsubscribe function
- `WritableDataPublisher` concrete implementation with `publish(channelName, data)` for testing
- `createStreamFromDataPublisher` converting DataPublisher to Dart `Stream<TData>` with error channel support
- `createAsyncIterableFromDataPublisher` with AbortSignal support, message queuing, and pre-poll message dropping
- `demultiplexDataPublisher` splitting single channel into multiple typed channels with lazy subscription and reference counting
- Idempotent unsubscribe and proper cleanup on abort
