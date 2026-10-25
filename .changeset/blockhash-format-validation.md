---
"solana_kit_transaction_messages": patch
"solana_kit_errors": patch
---

# Validate blockhash format before it reaches the wire

The wire format stores a blockhash lifetime token as a fixed 32-byte value, but nothing validated the constraint's string: a blockhash whose base58 decoding was not exactly 32 bytes — for example one served by a compromised RPC — was silently truncated or zero-extended by the fixed-size encoder, producing a signed transaction whose lifetime token differs from the string shown to the caller. `setTransactionMessageLifetimeUsingBlockhash` now rejects such values with the new `SolanaErrorCode.transactionInvalidBlockhashFormat` (port-only code `5663043`), the blockhash counterpart of the existing `transactionInvalidNonceFormat` check.
