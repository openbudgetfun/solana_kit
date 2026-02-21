# Changelog

All notable changes to this package will be documented in this file.

## 0.1.0 (2026-02-21)

### Notes

- First 0.1.0 release of this package.

## 0.0.2 (2026-02-21)

### Features

#### Implement `solana_kit_codecs_core` and `solana_kit_codecs_numbers` packages, ported

from `@solana/codecs-core` and `@solana/codecs-numbers` in the TypeScript SDK.

**solana_kit_codecs_core** provides the foundational codec interfaces and utilities:

- Sealed class hierarchy: `Encoder<T>`, `Decoder<T>`, `Codec<TFrom, TTo>` with
  fixed-size and variable-size variants
- Composition utilities: `combineCodec`, `transformCodec`, `fixCodecSize`,
  `reverseCodec`, `addCodecSentinel`, `addCodecSizePrefix`, `offsetCodec`,
  `padCodec`, `resizeCodec`
- Byte utilities: `mergeBytes`, `padBytes`, `fixBytes`, `containsBytes`
- Assertion helpers for byte array validation
- 135 tests covering all codec operations

**solana_kit_codecs_numbers** provides number encoding/decoding:

- Integer codecs: u8, i8, u16, i16, u32, i32, u64, i64, u128, i128
- Float codecs: f32, f64
- Variable-size shortU16 codec (Solana compact encoding)
- Configurable endianness (little-endian default, big-endian option)
- BigInt support for 64-bit and 128-bit integers
- 152 tests including exhaustive shortU16 roundtrip validation

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
