---
"solana_kit_codecs_data_structures": patch
"solana_kit_errors": patch
---

# Reject non-canonical boolean decoder values

Boolean codecs now reject values other than zero and one with a typed error, including nullable prefixes that use boolean tags.
