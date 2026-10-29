---
"solana_kit_transaction_introspection": minor
---

# Decode the v1 transaction config from `json` RPC responses

Ports #2132 from `@solana/transaction-introspection` v8.6.0: `decodeTransactionFromRpcResponse` now reads `message.transactionConfig` from a version 1 `'json'`-encoded response and fills the compiled message's `configMask` and `configValues`, matching what the `base64` and `base58` decoders already produced. Previously the synthesized v1 message always reported an empty config.
