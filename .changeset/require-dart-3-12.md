---
"solana_kit": major
"solana_kit_accounts": major
"solana_kit_address_lookup_table": major
"solana_kit_addresses": major
"solana_kit_associated_token_account": major
"solana_kit_codecs": major
"solana_kit_codecs_core": major
"solana_kit_codecs_data_structures": major
"solana_kit_codecs_numbers": major
"solana_kit_codecs_strings": major
"solana_kit_compute_budget": major
"solana_kit_config": major
"solana_kit_errors": major
"solana_kit_fast_stable_stringify": major
"solana_kit_fixed_points": major
"solana_kit_functional": major
"solana_kit_helius": major
"solana_kit_instruction_plans": major
"solana_kit_instructions": major
"solana_kit_keys": major
"solana_kit_loader": major
"solana_kit_memo": major
"solana_kit_mobile_wallet_adapter": major
"solana_kit_mobile_wallet_adapter_protocol": major
"solana_kit_mpl_bubblegum": major
"solana_kit_offchain_messages": major
"solana_kit_options": major
"solana_kit_program_client_core": major
"solana_kit_programs": major
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
"solana_kit_spl_account_compression": major
"solana_kit_stake": major
"solana_kit_subscribable": major
"solana_kit_system": major
"solana_kit_sysvars": major
"solana_kit_token": major
"solana_kit_token_2022": major
"solana_kit_transaction_confirmation": major
"solana_kit_transaction_messages": major
"solana_kit_transactions": major
---

# Raise minimum Dart SDK to 3.12

Raise the minimum supported Dart SDK constraint to `^3.12.0` across public Dart packages.

This is a breaking change because consumers must use Dart 3.12 or newer. Flutter consumers must use a Flutter SDK that bundles Dart 3.12 or newer.

```yaml
environment:
  sdk: ^3.12.0
```
