---
"solana_kit_accounts": minor
---

# Add SolanaAccountClient as the single implementation…

Add `SolanaAccountClient` as the single implementation layer for `fetchEncodedAccount`, `fetchEncodedAccounts`, `fetchJsonParsedAccount`, and `fetchJsonParsedAccounts`, delegating all RPC calls through typed API methods instead of raw request maps. Extract `FetchAccountConfig` into its own file. Migrate parse helpers from `Map<String, dynamic>` to `Map<String, Object?>`. Switch error construction to the standardized `createSolanaError` and `wrapSolanaError` helpers with `SolanaErrorContextKeys`.
