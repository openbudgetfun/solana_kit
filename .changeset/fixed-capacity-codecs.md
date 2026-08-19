---
"solana_kit_codecs_core": patch
"codama-renderers-dart": patch
---

# Reject over-capacity generated values

Adds an opt-in non-truncating mode to fixed-size encoders and codecs. Codama fixed-size types now use that mode so generated string, byte, and collection encoders pad values within capacity but reject oversized encoded values.
