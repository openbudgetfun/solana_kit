---
"solana_kit_codecs_data_structures": minor
"solana_kit_codecs_numbers": minor
"solana_kit": docs
---

Add typed `getTuple2Encoder`/`getTuple2Decoder` helpers to `solana_kit_codecs_data_structures`, exposing two-element tuples as Dart records. Narrow the integer encoders in `solana_kit_codecs_numbers` (u8/i8/u16/i16/u32) to `FixedSizeEncoder<int>` so they satisfy strict typed contexts; float codecs and `shortU16` keep their existing types. `codama-renderers-dart` now emits `getTuple2*` for arity-2 tuple nodes, escapes Dart reserved-word identifiers, and keeps generated `instructionData` locals collision-free.
