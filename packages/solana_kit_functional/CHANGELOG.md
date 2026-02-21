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

#### Implement foundation utility packages ported from the `@solana/functional` and

`@solana/fast-stable-stringify` TypeScript packages.

**solana_kit_functional**: Adds the `Pipe` extension which provides a `.pipe()`
method on any value for composable functional pipelines. This is the idiomatic
Dart equivalent of the TS `pipe()` function, used extensively for building
transaction messages. Includes 28 tests covering single/multiple transforms,
type changes, object mutation, combining, nested pipes, and error propagation.

**solana_kit_fast_stable_stringify**: Adds `fastStableStringify()` for
deterministic JSON serialization with sorted object keys. Handles all Dart
primitives, BigInt (serialized as `<value>n`), nested maps, lists, and objects
implementing `ToJsonable`. Includes 15 tests matching the upstream SDK's
`json-stable-stringify` reference output.
