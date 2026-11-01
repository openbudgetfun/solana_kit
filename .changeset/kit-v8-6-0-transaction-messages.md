---
"solana_kit_transaction_messages": minor
---

# Export `decompileTransactionConfig`

Ports #2134 from `@solana/transaction-messages` v8.6.0: `decompileTransactionConfig(configMask, configValues)` decodes the compiled config of a version 1 transaction message into a `V1TransactionConfig` without decompiling the whole message. The decompiler now delegates to it, preserving existing empty-config-to-null semantics. Config values that are missing, unexpected, or of the wrong kind still throw as before.
