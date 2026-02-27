# Changelog

All notable changes to this package will be documented in this file.

## 0.2.0 (2026-02-27)

### Breaking Changes

#### Initial Release

The initial release of all libraries.

### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for foundational utility packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

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
