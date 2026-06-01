---
"solana_kit_helius": patch
"solana_kit_mobile_wallet_adapter_protocol": patch
---

# Harden security audit findings

Disable placeholder Helius auth signing, redact Helius API keys from JSON-RPC error context, validate malformed encrypted mobile-wallet messages before slicing, and reject negative mobile-wallet sequence numbers.
