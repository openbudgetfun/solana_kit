---
"solana_kit_instruction_plans": patch
---

# Preserve instructions across transaction packing

Keep overflowing instructions pending for the next message instead of returning oversized messages that can lose already packed instructions. Abort planning if a message update overflows after a stateful packer has consumed instructions, preserving transaction-plan integrity.

Preserve the original execution error and partial result tree when an executor callback fails with an unsigned transaction in its context, so callers can still identify earlier successful transactions.
