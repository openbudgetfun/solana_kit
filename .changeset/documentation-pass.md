---
"solana_kit_programs": patch
"solana_kit_config": patch
"solana_kit_subscriptions": patch
"solana_kit_stake": patch
"solana_kit_memo": patch
"solana_kit_compute_budget": patch
"solana_kit_address_lookup_table": patch
"solana_kit_codecs": patch
"solana_kit_rpc_parsed_types": patch
"solana_kit_rpc_spec_types": patch
"solana_kit_offchain_messages": patch
"solana_kit_program_client_core": patch
"solana_kit_fixed_points": patch
---

# Document program errors and the generated program-client contract

Add library doc comments synchronized from shared MDT sections to thirteen packages: program error matching (`isProgramError` + `TransactionMessageInput`) and the generated program-client API shape are now documented inline in each library and in the errors docs page; six barrels that had no library doc comment gain one; three one-line library headers are expanded. No code changes.
