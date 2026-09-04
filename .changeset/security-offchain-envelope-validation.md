---
"solana_kit_offchain_messages": patch
---

# Validate offchain message envelopes

Validate complete offchain messages before signing, verifying, or encoding and decoding envelopes. Check signature completeness against the required signers encoded in the message, and preserve newly created signatures when their map entries were omitted. Correct the signing example to use the generated key pair's address.
