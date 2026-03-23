---
solana_kit: minor
solana_kit_addresses: patch
solana_kit_rpc: minor
solana_kit_rpc_spec_types: patch
solana_kit_transaction_confirmation: minor
solana_kit_transactions: patch
codama_renderers: patch
---

Add additive next-step ergonomics and maintenance tooling without breaking the existing lower-level APIs.

- Add `Rpc.getEpochInfo()` to the typed RPC convenience surface.
- Add polling-based `waitForTransactionConfirmation(...)` and `sendAndConfirmTransaction(...)` helpers for signed transactions.
- Add local benchmark scripts for address validation, transaction wire encoding, and BigInt-aware JSON parsing.
- Add an upstream compatibility metadata check script plus CI coverage.
- Complete Codama PDA rendering by generating `getProgramDerivedAddress(...)` calls instead of `UnimplementedError` placeholders.
- Expand READMEs and docs to explain the new workflows.
