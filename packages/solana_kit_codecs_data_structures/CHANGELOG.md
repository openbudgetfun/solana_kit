# Changelog

All notable changes to this package will be documented in this file.

## 0.0.2 (2026-02-21)

### Features

#### Implement codecs_strings and codecs_data_structures packages ported from the

TypeScript `@solana/codecs-strings` and `@solana/codecs-data-structures`.

**codecs_strings** (15 tests):

- UTF-8 codec using dart:convert with null character stripping
- Base16 (hex) codec with optimized nibble conversion
- Base58 codec using BigInt arithmetic for Solana address encoding
- Base64 codec tolerant of missing padding (matches Node.js behavior)
- Base10 codec for decimal string encoding
- Generic baseX codec for arbitrary alphabets
- BaseX reslice codec for power-of-2 bases using bit accumulator

**codecs_data_structures** (90 tests):

- Unit (void), boolean, and raw bytes codecs
- Array codec with prefix/fixed/remainder sizing (sealed ArrayLikeCodecSize)
- Tuple codec for heterogeneous fixed-length lists
- Struct codec using Map<String, Object?> for named fields
- Map and Set codecs built on array internals
- Nullable codec with configurable none representation (sealed NoneValue)
- Bit array codec with forward/backward bit ordering
- Constant, hidden prefix, and hidden suffix codecs
- Union, discriminated union, and literal union codecs

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
