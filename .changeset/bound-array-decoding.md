---
"solana_kit_codecs_data_structures": patch
---

# Bound array decoding from untrusted bytes

Reject missing, invalid, and excessive array counts, and stop remainder decoders that fail to consume input. Callers can set a smaller `maxItems` limit for application-specific formats.
