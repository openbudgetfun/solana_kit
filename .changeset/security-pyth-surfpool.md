---
"solana_kit_pyth": patch
"solana_kit_integration_tests": patch
"solana_kit_sns": patch
---

# Harden Pyth and SNS validation

Require the Pyth price-update account signer declared by the receiver IDL, validate Pyth account headers and bounded integer inputs, normalize malformed update data to typed decode errors, and cover the signer requirement through the Surfpool transaction flow. Also enforce SNS record lengths, EVM address sizes, and TLD-trimmed domain-key inputs.
