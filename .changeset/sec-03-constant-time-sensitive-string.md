---
"solana_kit_helius": patch
---

# Constant-time comparison for sensitive strings

SEC-03: Use constant-time comparison for SensitiveString equality to prevent timing side-channel attacks.

- SensitiveString.operator== now uses constant-time byte comparison
- Prevents attackers from learning how many characters match between two secrets
- Added test verifying no early exit on mismatch
