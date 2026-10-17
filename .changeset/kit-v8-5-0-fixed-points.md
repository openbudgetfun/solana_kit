---
"solana_kit_fixed_points": patch
---

# Allow binary fixed-points whose fractionalBits exceed totalBits

Ports the change from `@solana/fixed-points` v8.5.0 (#2102): binary fixed-point shapes where `fractionalBits` exceeds `totalBits` are now valid — e.g. an unsigned 8-bit value with 12 fractional bits represents values in `[0, 1/16)` — consistently with decimal fixed-points whose `decimals` may already exceed their `totalBits`. Values whose raw form does not fit in `totalBits` bits still fail the existing range checks.
