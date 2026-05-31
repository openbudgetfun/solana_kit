---
"solana_kit_addresses": test
"solana_kit_associated_token_account": test
"solana_kit_codecs_core": test
"solana_kit_codecs_data_structures": test
"solana_kit_codecs_strings": test
"solana_kit_errors": test
"solana_kit_fast_stable_stringify": test
"solana_kit_instruction_plans": test
"solana_kit_keys": test
"solana_kit_rpc": test
"solana_kit_rpc_api": test
"solana_kit_rpc_parsed_types": test
"solana_kit_rpc_spec": test
"solana_kit_rpc_transformers": test
"solana_kit_rpc_types": test
"solana_kit_signers": test
"solana_kit_subscribable": test
"solana_kit_transaction_confirmation": test
"solana_kit_transaction_messages": test
"solana_kit_transactions": test
---

# Improve test coverage to 95%+ across all packages

Added 500+ tests covering equality/hashCode/toString, codec edge cases, error paths, and constructor variants. Removed dead code in fast_stable_stringify. Fixed concurrent modification bug in subscribable.
