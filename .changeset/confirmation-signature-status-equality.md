---
"solana_kit_transaction_confirmation": patch
---

# Add ==

Add `==`, `hashCode`, and `toString` to `SignatureStatus` for structural equality support.

`SignatureStatus` now implements value-type equality based on its `confirmationStatus` and `err` fields. This enables correct behavior when using `SignatureStatus` instances in `Set`s, as `Map` keys, and in test assertions that compare expected vs. actual status values.

A `toString` override is also included for readable diagnostics during debugging and test failure output.

This completes the value-semantics initiative (issue #114) for the transaction confirmation package, which was listed in the original scope but omitted from the changeset frontmatter.
