---
"solana_kit_anchor": patch
---

# Validate Anchor IDL discriminators

Reject missing, empty, non-integer, and out-of-range instruction, account, and event discriminators during IDL parsing. Preserve valid custom lengths and make parsed discriminator bytes immutable. Prevent empty discriminators from matching instruction, account, or event payloads, including when IDL entries are constructed manually.
