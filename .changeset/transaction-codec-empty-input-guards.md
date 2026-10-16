---
"solana_kit_transactions": patch
---

# Guard transaction encoding and decoding against empty and truncated bytes

Three upstream error codes were defined but never thrown, and the paths they describe failed with less useful errors:

- Encoding a transaction with empty message bytes produced a signatures-first wire envelope of a zero-length message; it now throws `transactionCannotEncodeWithEmptyMessageBytes`.
- Decoding an empty byte array failed inside the shortU16 codec; it now throws `transactionCannotDecodeEmptyTransactionBytes`.
- A signature count larger than the remaining bytes can hold failed inside the signature reader with a range error; it now throws `transactionSignatureCountTooHighForTransactionBytes` with the expected count and byte length in the context.
