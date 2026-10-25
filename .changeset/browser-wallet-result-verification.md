---
"solana_kit_wallet_adapter": patch
---

# Verify browser wallet signing results

Reject unverified browser wallet signing results. Check result counts, verify Ed25519 signatures, bind signed transactions and messages to their requests, validate every supplied sign-in challenge field and authorized account, and preserve offchain content and required signers. Copy request bytes before passing them to JavaScript so wallet providers cannot mutate the original request.
