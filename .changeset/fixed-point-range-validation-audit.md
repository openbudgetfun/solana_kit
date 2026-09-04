---
"solana_kit_fixed_points": patch
---

# Validate fixed-point ranges

Reject signed fixed-point values outside their declared range before encoding, preventing positive and negative values from wrapping into the opposite sign on the wire. Validate fixed-point shapes in assertion helpers and reject digit-free decimal input instead of parsing it as zero. Add regression tests for both fixed-point representations, byte orders, and signed range boundaries.
