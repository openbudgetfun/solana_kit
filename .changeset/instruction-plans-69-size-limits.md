---
"solana_kit_instruction_plans": patch
---

# Use version-aware transaction size limits

Make transaction planning use version-aware…


Make transaction planning use version-aware transaction-message size limits, preserve compile-time transaction limit precedence, and retry packing with the correct transaction limit behavior when a plan exceeds Agave packet constraints.
