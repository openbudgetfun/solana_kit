---
"solana_kit_helius": minor
---

# Require secure transport for Sender submissions

Reject plaintext regional Sender endpoints before submitting transactions or bundles. The HTTPS default retains automatic region routing. Regional HTTP requires an explicit `allowInsecureHttpForTesting` opt-in in non-release builds and is always rejected in release builds, including by the Sender URL helpers.
