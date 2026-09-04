---
"solana_kit_anchor": patch
"solana_kit_integration_tests": patch
---

# Restore Anchor runtime error compatibility

Align the standard Anchor error table with `anchor-lang` 0.31.1 so errors returned by deployed Anchor programs resolve to the correct code, name, and message.

Add live Surfpool compatibility coverage for Anchor, Metaplex Core, Metaplex Token Metadata, Squads V4, RPC subscriptions, transaction introspection, lookup tables, instruction plans, and transaction immutability.
