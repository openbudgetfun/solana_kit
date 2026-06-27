---
"solana_kit_rpc_types": major
---

# Remove deprecated TransactionStatus types

Removes the deprecated `TransactionStatus` sealed class and its `TransactionStatusOk` / `TransactionStatusErr` subclasses. The modern API uses a nullable `TransactionError` — `null` means success, non-null means the transaction failed with that error.

```dart
// Before
final status = TransactionStatusOk();
final error = TransactionStatusErr(TransactionErrorSimple('AccountInUse'));

// After — use nullable TransactionError directly
final error = null; // success
final error = TransactionErrorSimple('AccountInUse'); // failure
```
