---
"solana_kit_rpc_types": major
---

# Remove deprecated base58 account info types

Removes the deprecated `AccountInfoWithBase58Bytes` and `AccountInfoWithBase58EncodedData` classes. The Solana RPC API now returns account data as base64 (or base64+zstd) instead of base58. Use `AccountInfoWithBase64EncodedData` instead.

```dart
// Before
final account = AccountInfoWithBase58Bytes(data: Base58EncodedBytes('...'));

// After
final account = AccountInfoWithBase64EncodedData(
  data: (Base64EncodedBytes('...'), 'base64'),
);
```
