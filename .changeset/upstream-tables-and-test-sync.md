---
"solana_kit_address_lookup_table": patch
"solana_kit_associated_token_account": patch
"solana_kit_attestation_service": patch
"solana_kit_compute_budget": patch
"solana_kit_config": patch
"solana_kit_loader": patch
"solana_kit_memo": patch
"solana_kit_mobile_wallet_adapter": patch
"solana_kit_mobile_wallet_adapter_protocol": patch
"solana_kit_rpc_types": patch
"solana_kit_spl_account_compression": patch
"solana_kit_stake": patch
"solana_kit_subscriptions": patch
"solana_kit_system": patch
"solana_kit_token": patch
"solana_kit_token_2022": patch
"solana_kit_transaction_introspection": patch
---

# Refresh generated upstream version tables and align validation tests

Regenerate the upstream version tables embedded in the generated program-client READMEs after the 2026-10-12 release (docs-only, produced by `docs:update`), and update two validation tests to the address-scoped error code now thrown for non-base58 strings: `assertIsBlockhash` and the RPC transaction decoder's loaded-address checks expect `addressesInvalidBase58EncodedAddress` instead of the codec-internal error that used to leak through.
