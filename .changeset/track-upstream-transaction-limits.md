---
"solana_kit": patch
"solana_kit_codecs": patch
"solana_kit_codecs_core": patch
"solana_kit_errors": patch
"solana_kit_fixed_points": patch
"solana_kit_keys": patch
"solana_kit_instruction_plans": patch
"solana_kit_mobile_wallet_adapter": patch
"solana_kit_rpc_api": patch
"solana_kit_rpc_parsed_types": patch
"solana_kit_rpc_subscriptions": patch
"solana_kit_rpc_subscriptions_channel_websocket": patch
"solana_kit_rpc_types": patch
"solana_kit_subscribable": patch
"solana_kit_transaction_messages": patch
"solana_kit_transactions": patch
"solana_kit_signers": patch
---

Track upstream transaction constraint limits from @solana/kit 6.9.0, including signer/account/instruction count errors, fixed-point helpers and filesystem error codes, Agave transaction and transaction-message size helpers/constants, compile-time transaction limit precedence, instruction-plan packing with version-aware message limits and transaction-limit retry handling, equivalent noop signer deduplication, key pair file writing helpers, key pair and key-pair signer grinding helpers, SOL/Lamports conversion and codec helpers, byte containment compatibility for negative offsets, simulate transaction result metadata types, sendTransaction preflight metadata defaults, Agave v3 parsed vote-account fields, compute unit limit message helpers, Dart-native client plugin composition and capability interface helpers, a data-publisher reactive store helper, pending RPC subscription reactive-store helpers, abortable future helpers, and slot-tracking stream/reactive-store helpers for initial RPC values plus subscription updates.
