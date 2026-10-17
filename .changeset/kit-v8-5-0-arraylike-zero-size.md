---
"solana_kit_codecs_data_structures": patch
---

# Reject zero-byte item codecs with sentinel and remainder strategies

Ports the fix from `@solana/codecs-data-structures` v8.5.0 (#2089): constructing an `array`, `set`, or `map` codec whose item codec has a fixed size of zero with the sentinel or remainder size strategy now throws `codecsUnexpectedZeroFixedSizeItemForArrayLikeSizeStrategy` at construction time, on both the encoder and the decoder. A zero-byte item can never advance past a sentinel boundary or toward the end of the byte array, so decoding such a combination previously pushed elements until memory ran out. Zero-byte item codecs remain allowed when the collection size is explicit. The runtime zero-progress loop guards added in earlier port work remain as defense in depth.
