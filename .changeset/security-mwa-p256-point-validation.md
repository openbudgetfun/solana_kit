---
"solana_kit_mobile_wallet_adapter_protocol": patch
---

# Validate P-256 points before wallet key agreement

Reject malformed P-256 public points and mismatched curve parameters before wallet session key agreement. Validate imported public keys against the curve equation so invalid points cannot produce predictable shared secrets.
