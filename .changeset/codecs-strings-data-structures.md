---
solana_kit_codecs_strings: minor
solana_kit_codecs_data_structures: minor
---

Implement codecs_strings and codecs_data_structures packages ported from the
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
