---
"solana_kit_signers": patch
---

# Deduplicate equivalent noop signers

Align signer utilities with upstream 6.9 by deduplicating…

Align signer utilities with upstream 6.9 by deduplicating equivalent noop signers, preserving fee-payer signer config when transaction message config changes, supporting key-pair signer grinding helpers, and including useful assertion context for invalid signer-like values.
