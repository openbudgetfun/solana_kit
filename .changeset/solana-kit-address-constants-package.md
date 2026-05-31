---
"solana_kit_address_constants": minor
---

Extract well-known address constants (program addresses, sysvar addresses, SPL program addresses, Metaplex addresses, and token mint addresses) from `solana_kit_addresses` into a standalone `solana_kit_address_constants` package.

This package depends only on `solana_kit_address` and provides centralized constants without requiring the full address module.