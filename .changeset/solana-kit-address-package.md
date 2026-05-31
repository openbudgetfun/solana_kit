---
"solana_kit_address": minor
---

Extract the core `Address` extension type, codecs, comparator, and `PublicKey` helpers from `solana_kit_addresses` into a standalone `solana_kit_address` package.

This allows other packages to depend on the address primitives without pulling in well-known address constants or program-derived address logic.