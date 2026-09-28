---
"solana_kit_errors": patch
"solana_kit_transaction_messages": patch
"solana_kit_transactions": patch
"solana_kit_transaction_confirmation": patch
"solana_kit_transaction_introspection": minor
"solana_kit_signers": patch
---

# Harden transaction lifetime, confirmation, and introspection boundaries

Durable nonce values are now format-checked when a nonce lifetime is set: a nonce that is not a base58 string decoding to exactly 32 bytes throws `transactionInvalidNonceFormat` instead of being silently truncated or zero-extended by the fixed-size lifetime-token encoder.

On-chain transaction failures now surface as typed `SolanaError`s (via the existing transaction-error mapper, matching upstream) instead of bare `StateError`s, in both the confirmation strategies and `sendAndConfirmTransaction` — callers that already catch `SolanaError` no longer miss transaction failures. `sendAndConfirmTransaction` also verifies that the signature the RPC returns for a submitted transaction equals the locally computed fee-payer signature, throwing `transactionReportedSignatureMismatch` when an RPC reports a different transaction than the one sent.

`DecodedRpcTransaction` gained an `err` field (and a `failed` getter) carrying the response's `meta.err` verbatim, so introspection consumers can tell a failed transaction's attempted instructions from a successful one's. Decoding now also rejects malformed account keys and headers with typed errors — `getAccountMetasFromCompiledTransactionMessage` throws `transactionIntrospectionHeaderAccountsMismatch` when header counts exceed the static account list, RPC account keys run through address validation, and `decompileTransactionMessage` bounds-checks instruction account indices — instead of crashing with raw `RangeError`s. Reconstructed wire lifetimes document their unknown-expiry semantics, and `signAndSendTransactionMessageWithSigners` documents that its returned signature records submission, not execution.
