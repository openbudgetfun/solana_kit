---
"codama-renderers-dart": fix
"solana_kit": fix
"solana_kit_accounts": fix
"solana_kit_address": fix
"solana_kit_address_constants": fix
"solana_kit_address_lookup_table": fix
"solana_kit_addresses": fix
"solana_kit_anchor": fix
"solana_kit_associated_token_account": fix
"solana_kit_attestation_service": fix
"solana_kit_codecs_core": fix
"solana_kit_codecs_data_structures": fix
"solana_kit_codecs_numbers": fix
"solana_kit_codecs_strings": fix
"solana_kit_compute_budget": fix
"solana_kit_config": fix
"solana_kit_dapp_publisher_cli": fix
"solana_kit_errors": fix
"solana_kit_fast_stable_stringify": fix
"solana_kit_fixed_points": fix
"solana_kit_helius": fix
"solana_kit_instruction_plans": fix
"solana_kit_instructions": fix
"solana_kit_integration_tests": fix
"solana_kit_jupiter": fix
"solana_kit_keys": fix
"solana_kit_loader": fix
"solana_kit_memo": fix
"solana_kit_mobile_wallet_adapter": fix
"solana_kit_mobile_wallet_adapter_protocol": fix
"solana_kit_mpl_bubblegum": fix
"solana_kit_mpl_core": fix
"solana_kit_mpl_token_metadata": fix
"solana_kit_offchain_messages": fix
"solana_kit_options": fix
"solana_kit_program_client_core": fix
"solana_kit_pyth": fix
"solana_kit_rpc": fix
"solana_kit_rpc_api": fix
"solana_kit_rpc_parsed_types": fix
"solana_kit_rpc_spec": fix
"solana_kit_rpc_spec_types": fix
"solana_kit_rpc_subscriptions": fix
"solana_kit_rpc_subscriptions_api": fix
"solana_kit_rpc_subscriptions_channel_websocket": fix
"solana_kit_rpc_transformers": fix
"solana_kit_rpc_transport_http": fix
"solana_kit_rpc_types": fix
"solana_kit_signers": fix
"solana_kit_sns": fix
"solana_kit_spl_account_compression": fix
"solana_kit_squads": fix
"solana_kit_stake": fix
"solana_kit_subscribable": fix
"solana_kit_subscriptions": fix
"solana_kit_surfpool": fix
"solana_kit_sysvars": fix
"solana_kit_test_matchers": fix
"solana_kit_token": fix
"solana_kit_token_2022": fix
"solana_kit_transaction_confirmation": fix
"solana_kit_transaction_introspection": fix
"solana_kit_transaction_messages": fix
"solana_kit_transactions": fix
"solana_kit_wallet_adapter": fix
"solana_kit_wallet_standard": fix
"solana_kit_wallet_ui": fix
---


# Monostyle style pass

Blank-line breathing room around control flow and returns, group splits, and collapsed blank runs, applied by `monostyle fix` and kept where dprint puts them. No behavior change: the renderers' emitted code and every package's API are untouched.
