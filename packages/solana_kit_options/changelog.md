# Changelog

All notable changes to this package will be documented in this file.

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

#### Implement options package and codecs umbrella re-export.

**solana_kit_options** (90 tests):

- Rust-like `Option<T>` sealed class with `Some<T>` and `None<T>` subclasses
- Option codec with 6 encoding modes: prefix-based, zeroes, custom none value,
  combined prefix+zeroes, combined prefix+custom, and absence-based detection
- `unwrapOption()` and `unwrapOptionOr()` for extracting values with fallback
- `wrapNullable()` for converting `T?` to `Option<T>`
- `unwrapOptionRecursively()` for deep unwrapping of nested Options in Maps/Lists

**solana_kit_codecs** (umbrella):

- Re-exports all codec sub-packages: core, numbers, strings, data structures
- Re-exports options package (matching TypeScript `@solana/codecs` behavior)
