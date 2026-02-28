---
solana_kit_transactions: minor
---

Harden transaction lifetime typing and compilation invariants.

- Replace `TransactionLifetimeConstraint` `Object` alias with a sealed hierarchy.
- Remove the internal `_NoLifetime` fallback from `compileTransaction`.
- Enforce lifetime presence during compile and throw explicit `SolanaErrorCode`
  values for invalid lifetime states.
- Expand transaction compile tests for missing and invalid lifetime paths.
