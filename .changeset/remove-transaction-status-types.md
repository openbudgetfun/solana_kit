---
"solana_kit_rpc_types": major
---

# Remove deprecated TransactionStatus types

Removes the deprecated `TransactionStatus` sealed class and its `TransactionStatusOk` / `TransactionStatusErr` subclasses. The modern API uses a nullable `TransactionError` — `null` means success, non-null means the transaction failed with that error.
