---
"solana_kit_transaction_introspection": patch
---

# Validate introspected account metadata

Reject loaded-address counts that disagree with compiled lookup tables before resolving account indices, preventing malformed RPC metadata from shifting account identities and roles. Reject duplicate inner-instruction groups instead of emitting repeated execution traces.
