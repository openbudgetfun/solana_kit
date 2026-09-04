---
"solana_kit_transactions": patch
"solana_kit_signers": patch
---

# Protect transaction signing integrity

Freeze transaction message and signature buffers so retained references cannot change reviewed signing payloads. Decode v1 message-first transaction envelopes with the correct signature ordering. Preserve v1 configuration when attaching signers and honor fee payer address replacements without retaining the old fee payer signer.
