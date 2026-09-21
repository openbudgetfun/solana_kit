---
"solana_kit_instruction_plans": major
---

# Remove the deprecated transaction-result helper

`successfulSingleTransactionPlanResultFromTransaction` is gone. It derived a result's `signature` by calling `getSignatureFromTransaction`, which throws when the transaction's fee payer has not signed; passing the context explicitly makes that step visible and lets the caller decide how to handle an unsigned transaction before it becomes an exception.

The executor no longer needs it: it keeps the same derivation as a private helper, so `TransactionPlanExecutor` results are unchanged.

```dart
// Before
final result = successfulSingleTransactionPlanResultFromTransaction(
  message,
  transaction,
);

// After
final result = successfulSingleTransactionPlanResult(message, {
  'signature': getSignatureFromTransaction(transaction),
  'transaction': transaction,
});
```

Callers that only need the signature can pass just that key.
