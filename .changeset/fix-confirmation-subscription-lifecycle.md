---
"solana_kit_transaction_confirmation": patch
---

# Fix confirmation subscription lifecycle

Settle cancelled confirmation strategies, propagate subscription failures and unexpected closure, and preserve slot notifications received during the initial block-height lookup.
