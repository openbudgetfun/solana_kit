---
"solana_kit_options": patch
"solana_kit_codecs_strings": patch
---

# Validate option and hexadecimal wire inputs

Reject invalid option presence flags, truncated None padding, and mismatched constant None markers. Reject incomplete hexadecimal byte pairs that previously lost their final character and returned incorrect write offsets.
