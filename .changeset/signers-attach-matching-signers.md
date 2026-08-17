---
"solana_kit_signers": patch
---

# Attach signers to any matching account meta

`addSignersToInstruction` (and `addSignersToTransactionMessage`) previously only attached a provided signer to an account meta that already declared a signer role (`readonlySigner`/`writableSigner`). Account metas whose role was plain `readonly`/`writable` were silently skipped, even when a signer for that exact address was supplied.

This dropped required signatures for programs whose IDLs mark authority accounts as non-signers. MPL Bubblegum is the canonical example: its `transfer`/`burn` instructions mark `leafOwner`/`leafDelegate` as readonly accounts, yet the program requires the leaf owner (or delegate) to sign (`LeafAuthorityMustSign`). The JS SDK handles this by promoting any account whose address matches a provided signer to `isSigner: true` in `getAccountMetasAndSigners`.

The Dart helpers now mirror that behavior: any account whose address matches a provided signer is wrapped in an `AccountSignerMeta` with its role upgraded via `upgradeRoleToSigner`, and the signer is attached. This fixes signature collection for Bubblegum transfers/burns and any other program with non-signer-marked authority accounts.
