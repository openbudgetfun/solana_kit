---
"solana_kit": major
"solana_kit_accounts": major
"solana_kit_address": major
"solana_kit_address_constants": major
"solana_kit_address_lookup_table": major
"solana_kit_addresses": major
"solana_kit_anchor": major
"solana_kit_associated_token_account": major
"solana_kit_attestation_service": major
"solana_kit_codecs": major
"solana_kit_codecs_core": major
"solana_kit_codecs_data_structures": major
"solana_kit_codecs_numbers": major
"solana_kit_codecs_strings": major
"solana_kit_compute_budget": major
"solana_kit_config": major
"solana_kit_dapp_publisher_cli": major
"solana_kit_errors": major
"solana_kit_fast_stable_stringify": major
"solana_kit_fixed_points": major
"solana_kit_functional": major
"solana_kit_helius": major
"solana_kit_instruction_plans": major
"solana_kit_instructions": major
"solana_kit_jupiter": major
"solana_kit_keys": major
"solana_kit_loader": major
"solana_kit_memo": major
"solana_kit_mobile_wallet_adapter": major
"solana_kit_mobile_wallet_adapter_protocol": major
"solana_kit_mpl_bubblegum": major
"solana_kit_mpl_core": major
"solana_kit_mpl_token_metadata": major
"solana_kit_offchain_messages": major
"solana_kit_options": major
"solana_kit_program_client_core": major
"solana_kit_programs": major
"solana_kit_pyth": major
"solana_kit_rpc": major
"solana_kit_rpc_api": major
"solana_kit_rpc_parsed_types": major
"solana_kit_rpc_spec": major
"solana_kit_rpc_spec_types": major
"solana_kit_rpc_subscriptions": major
"solana_kit_rpc_subscriptions_api": major
"solana_kit_rpc_subscriptions_channel_websocket": major
"solana_kit_rpc_transformers": major
"solana_kit_rpc_transport_http": major
"solana_kit_rpc_types": major
"solana_kit_signers": major
"solana_kit_sns": major
"solana_kit_spl_account_compression": major
"solana_kit_squads": major
"solana_kit_stake": major
"solana_kit_subscribable": major
"solana_kit_subscriptions": major
"solana_kit_surfpool": major
"solana_kit_system": major
"solana_kit_sysvars": major
"solana_kit_token": major
"solana_kit_token_2022": major
"solana_kit_transaction_confirmation": major
"solana_kit_transaction_introspection": major
"solana_kit_transaction_messages": major
"solana_kit_transactions": major
"solana_kit_wallet_adapter": major
"solana_kit_wallet_standard": major
"solana_kit_wallet_ui": major
---

# Raise the Dart and Flutter baseline

The workspace now builds against Dart 3.13.3 and Flutter 3.47.4, and every package declares that floor instead of the previous Dart 3.12 range. Consumers on older SDKs can no longer resolve these packages, so this release is breaking even though no Dart API changed.

The Flutter floor rises from 3.44 to 3.47 for `solana_kit_mobile_wallet_adapter`, `solana_kit_mobile_wallet_adapter_protocol`, and `solana_kit_wallet_adapter`, matching the floor `solana_kit_wallet_ui` already required. Every other package raises only the Dart SDK floor.

Align your own SDK constraint with the workspace:

```yaml
environment:
  sdk: ^3.13.0
  # Omit for pure Dart packages; required for the Flutter packages above.
  flutter: ">=3.47.0"
```
