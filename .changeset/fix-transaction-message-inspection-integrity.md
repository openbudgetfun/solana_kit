---
"solana_kit_transaction_messages": patch
---

# Preserve inspected transaction message data

Preserve v1 instructions, transaction version, and resource and priority fee configuration during decompilation. Reject inconsistent v1 instruction payloads and configuration values. Keep declared signer accounts static and materialize lookup accounts correctly when compiling legacy and v1 messages, preventing signer privilege loss and invalid account layouts.
