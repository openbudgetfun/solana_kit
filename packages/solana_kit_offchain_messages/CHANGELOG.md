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

#### Implement offchain messages package ported from `@solana/offchain-message`.

**solana_kit_offchain_messages** (1082 tests):

- `OffchainMessage` sealed class with `OffchainMessageV0` and `OffchainMessageV1` subtypes
- V0: application domain, three content formats (restricted ASCII 1232, UTF-8 1232, UTF-8 65535), signatory list
- V1: simplified with auto-sorted signatories and arbitrary UTF-8 content
- Content validation: ASCII character range (0x20-0x7E), size limits, format enforcement
- Application domain validation (must be valid 32-byte base58 address)
- Full codec suite: V0/V1/unified message codecs, envelope codec with signature handling
- `compileOffchainMessageEnvelope` to create signable envelopes from messages
- `partiallySignOffchainMessageEnvelope` and `signOffchainMessageEnvelope` for Ed25519 signing
- `verifyOffchainMessageEnvelope` for cryptographic signature verification
- Missing signatures encoded as 64 zero bytes in wire format
