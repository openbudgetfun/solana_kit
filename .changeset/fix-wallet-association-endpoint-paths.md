---
"solana_kit_mobile_wallet_adapter_protocol": patch
---

# Preserve wallet association endpoint paths

Preserve wallet-specific base URI path prefixes regardless of trailing slash. Identify local and remote associations by their endpoint suffix rather than substrings in wallet path prefixes, and reject unrelated paths.
