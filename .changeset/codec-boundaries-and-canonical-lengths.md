---
"solana_kit_codecs_core": patch
"solana_kit_codecs_numbers": patch
---

# Validate codec boundaries and compact lengths

Numeric codecs now keep reads and writes within the supplied byte view, preventing access to adjacent backing-buffer data. Short-u16 decoders reject overflowing values and overlong aliases so malformed compact lengths cannot be accepted as valid Solana wire data. Size-prefixed decoders reject negative, fractional, non-finite, and oversized lengths before decoding their contents.
