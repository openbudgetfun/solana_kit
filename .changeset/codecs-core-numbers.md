---
solana_kit_codecs_core: minor
solana_kit_codecs_numbers: minor
---

Implement `solana_kit_codecs_core` and `solana_kit_codecs_numbers` packages, ported
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
