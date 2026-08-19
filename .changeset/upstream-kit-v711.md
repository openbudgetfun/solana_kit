---
"solana_kit_codecs_strings": patch
"solana_kit_rpc_transformers": patch
"solana_kit_instruction_plans": patch
---

# Sync upstream `@solana/kit` v7.1.1

Tracks upstream APIs and behavior through `v7.1.1`:

- `solana_kit_codecs_strings`: base-X decoders now report the end of the buffer as the next offset when no bytes remain to decode, matching upstream `@solana/codecs-strings` (#1926).
- `solana_kit_rpc_transformers`: subscription responses for `blockSubscribe`/`blockNotification` now consult the `blockNotifications` numeric allow-list, matching upstream `@solana/rpc-transformers` (#1925).
- `solana_kit_instruction_plans`: `successfulSingleTransactionPlanResultFromTransaction` is deprecated in favor of `successfulSingleTransactionPlanResult` with an explicit context, matching upstream `@solana/instruction-plans` (#1924).
