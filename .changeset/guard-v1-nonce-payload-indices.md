---
"solana_kit_transactions": patch
---

# Tolerate version 1 messages with inconsistent instruction payloads

`getTransactionLifetimeConstraintFromCompiledTransactionMessage` no longer crashes with a bare `StateError: No element` when a version 1 message's instruction header claims three accounts but the payload carries a different number of account indices. Such header/payload disagreement is now treated as malformed data that is not an AdvanceNonceAccount instruction, matching how the legacy message path already classified it — the message falls back to a blockhash lifetime instead of throwing from an unguarded `.first`.
