---
"solana_kit_wallet_adapter": patch
---

# Decode native mobile wallet message signatures correctly

Request one signer for each native Mobile Wallet Adapter message batch and extract the 64-byte signature from each returned signed-message envelope. Reject inconsistent output counts, invalid encodings, incorrect signature lengths, and substituted message bytes before exposing signing results.
