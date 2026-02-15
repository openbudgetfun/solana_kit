---
solana_kit_signers: minor
---

Implement signers package ported from `@solana/signers`.

**solana_kit_signers** (88 tests):

- Five core signer interfaces: `MessagePartialSigner`, `MessageModifyingSigner`, `TransactionPartialSigner`, `TransactionModifyingSigner`, `TransactionSendingSigner`
- Composite types: `MessageSigner`, `TransactionSigner`, `KeyPairSigner` with Ed25519 signing
- `NoopSigner` for adding signature slots without actual signing
- `partiallySignTransactionMessageWithSigners` and `signTransactionMessageWithSigners` for signing transaction messages using attached signers
- `signAndSendTransactionMessageWithSigners` for combined sign-and-send workflow
- Signer extraction from instructions and transaction messages via account meta
- Fee payer signer utilities
- Signer deduplication and assertion helpers
