# Changelog

All notable changes to this package will be documented in this file.

## 0.0.2 (2026-02-21)

### Features

#### Implement addresses and keys packages ported from `@solana/addresses` and `@solana/keys`.

**solana_kit_addresses** (65 tests):

- `Address` extension type wrapping validated base58-encoded 32-byte strings
- Address codec (`getAddressEncoder`/`getAddressDecoder`/`getAddressCodec`) for 32-byte fixed-size encoding
- Address comparator with base58 collation rules matching Solana runtime ordering
- Ed25519 curve checking (`compressedPointBytesAreOnCurve`, `isOnCurveAddress`, `isOffCurveAddress`)
- PDA derivation (`getProgramDerivedAddress`) with SHA-256, bump seed search, and seed validation
- `createAddressWithSeed` for deterministic address derivation
- Public key to/from address conversion utilities

**solana_kit_keys** (36 tests):

- `Signature` and `SignatureBytes` extension types for Ed25519 signatures
- Key pair generation, creation from bytes, and creation from private key bytes
- Ed25519 sign/verify operations using `ed25519_edwards` package
- Signature validation (string length, byte length, base58 decoding)
- Private key validation and public key derivation

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

### Fixes

#### Enhance core SDK packages with additional functionality and tests.

- **Codecs core**: Enhanced `addCodecSizePrefix` with additional functionality
- **Codecs data structures**: Array codec improvements
- **Codecs numbers**: `shortU16` codec enhancements
- **Codecs strings**: UTF-8 codec improvements
- **Keys**: Key pair and signatures enhancements
- **RPC transport**: HTTP transport and WebSocket channel updates
- **Transactions**: Transaction codec enhancements
