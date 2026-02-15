---
solana_kit_transactions: minor
---

Implement transactions package ported from `@solana/transactions`.

**solana_kit_transactions** (64 tests):

- `Transaction` class with `messageBytes` (Uint8List) and `signatures` (Map<Address, SignatureBytes?>) fields
- `TransactionWithLifetime` with blockhash and durable nonce lifetime constraints
- `compileTransaction` to compile a TransactionMessage into a Transaction with signature slots and lifetime constraint
- `partiallySignTransaction` and `signTransaction` for async Ed25519 signing with key pairs
- `getSignatureFromTransaction` to extract fee payer signature
- `isFullySignedTransaction` / `assertIsFullySignedTransaction` for signature completeness checks
- Transaction size calculations with 1232-byte limit enforcement
- `isSendableTransaction` / `assertIsSendableTransaction` combining signature and size checks
- Wire format encoding with `getBase64EncodedWireTransaction`
- Full transaction codec: signatures encoder (shortU16 prefix + 64 bytes each), transaction encoder/decoder
