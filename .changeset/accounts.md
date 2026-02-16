---
solana_kit_accounts: minor
---

Implement accounts package ported from `@solana/accounts`.

**solana_kit_accounts** (45 tests):

- `Account<TData>` and `BaseAccount` with owner, lamports, executable, rentEpoch fields
- `EncodedAccount` typedef for base64-encoded account data
- `MaybeAccount<TData>` sealed class: `ExistingAccount` and `NonExistingAccount` variants
- `assertAccountExists()` and `assertAccountsExist()` for null-safe account unwrapping
- `parseBase64RpcAccount()`, `parseBase58RpcAccount()`, `parseJsonRpcAccount()` parsers
- `decodeAccount()`, `decodeMaybeAccount()` with codec-based data decoding
- `assertAccountDecoded()`, `assertAccountsDecoded()` for decoded type assertions
- `fetchEncodedAccount()`, `fetchEncodedAccounts()` via RPC `getAccountInfo`/`getMultipleAccounts`
- `fetchJsonParsedAccount()`, `fetchJsonParsedAccounts()` for JSON-parsed account data
