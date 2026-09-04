---
"solana_kit_compute_budget": patch
---

# Decode priority fees as unsigned integers

Preserve unsigned 64-bit compute unit prices when inspecting transaction messages and applying fee-capping updates, preventing high prices from appearing negative.
