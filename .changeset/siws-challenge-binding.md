---
"solana_kit_wallet_adapter": patch
"solana_kit_mobile_wallet_adapter_protocol": patch
---

# Bind native SIWS proofs to the requested challenge

Reject mobile Sign In With Solana proofs unless the signed bytes match the canonical message for the requested challenge and authorized account. This binds the nonce, origin, requested address, timestamps, request ID, and ordered resources, preventing valid signatures over stale or unrelated messages from satisfying a new request. Preserve trailing whitespace in SIWS field values so canonical serialization cannot collapse distinct challenges.
