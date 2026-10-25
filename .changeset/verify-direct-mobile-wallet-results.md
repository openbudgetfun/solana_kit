---
"solana_kit_mobile_wallet_adapter": patch
---

# Verify direct mobile wallet signing results

Verify direct `KitMobileWallet` signing responses before returning them. Reject incorrect output counts, changed transaction or message bytes, forged signatures, altered existing cosignatures, and sign-in proofs that do not match the authorized account and requested SIWS fields. Validate reported transaction IDs against the submitted message and fee payer. Signing now requires authorization or reauthorization through the same wrapper, and pending responses are rejected if authorization changes.
