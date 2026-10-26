---
"solana_kit_address_lookup_table": patch
"solana_kit_compute_budget": patch
"solana_kit_loader": patch
"solana_kit_mpl_bubblegum": patch
"solana_kit_spl_account_compression": patch
"solana_kit_stake": patch
"solana_kit_subscriptions": patch
"solana_kit_system": patch
"solana_kit_token": patch
"solana_kit_integration_tests": patch
---

# Reject incorrect instruction discriminators and trailing bytes

Reject incorrect instruction discriminators and trailing bytes in the remaining legacy generated instruction data decoders and named parsers. Preserve their existing data classes, encoder APIs, and decoder size metadata. Add regression coverage for instruction classification, truncated input, and nonzero decoder offsets.
