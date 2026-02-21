# Changelog

All notable changes to this package will be documented in this file.

## 0.1.0 (2026-02-21)

### Notes

- First 0.1.0 release of this package.

## 0.0.2 (2026-02-21)

### Features

#### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct
workspace dependencies, shared analysis_options.yaml, and an empty barrel export
file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec),
  fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages,
  transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

#### Implement subscribable package ported from `@solana/subscribable`.

**solana_kit_subscribable** (33 tests):

- `DataPublisher` interface with `on(channelName, subscriber)` returning unsubscribe function
- `WritableDataPublisher` concrete implementation with `publish(channelName, data)` for testing
- `createStreamFromDataPublisher` converting DataPublisher to Dart `Stream<TData>` with error channel support
- `createAsyncIterableFromDataPublisher` with AbortSignal support, message queuing, and pre-poll message dropping
- `demultiplexDataPublisher` splitting single channel into multiple typed channels with lazy subscription and reference counting
- Idempotent unsubscribe and proper cleanup on abort
