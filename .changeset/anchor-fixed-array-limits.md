---
"solana_kit_anchor": patch
"solana_kit_codecs_data_structures": minor
---

# Bound fixed-array lengths from runtime schemas

Anchor IDL type parsing rejects negative, fractional, non-finite, and excessive fixed-array lengths. The upper bound is one million items, shared with array decoders through the new `defaultMaxArrayItems` constant.

Fixed-array decoders now enforce `maxItems` during construction, before byte-size calculations or element reads. This prevents hostile schema lengths from expanding zero-byte elements into unbounded lists. Callers can still choose a different decoder limit with `maxItems`; valid empty arrays and zero-byte elements remain supported.
