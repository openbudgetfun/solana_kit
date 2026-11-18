---
"solana_kit_helius": minor
---

# Track `helius-labs/helius-sdk` `v3.5.0`

The reference pin advances to `v3.5.0`.

- **New beta Historical Account State reads** on `helius.rpcV2`: `getHistoricalAccountInfo` returns an account as it was at a past slot or transaction (null when it did not exist there), and `getHistoricalTokenAccountsByOwner` returns a page of the token accounts a wallet owned, with cursor pagination whose null `paginationKey` ends the scan. Typed requests and responses model the positional params (`[address, query, config]` with `{}` defaults), encodings, data slices, `mint`/`programId` filtering, and the corrected 25,000-account page limit (#403, #405). Mainnet only, from slot 444959999 onward.
- **Parsed Streams `onDisconnect`**: reports the close code and last delivered slot as soon as the connection drops — once per outage, never on an explicit `close()` — so backfill windows are known before `onReconnect` fires (#398).
- **Parsed Events request options**: `HeliusConfig.parsedEventsUrl` sends requests to another host (a proxy's query string survives next to the api key) and `HeliusConfig.parsedEventsTimeoutMs` time-limits every request with a `TimeoutException`; each method takes a per-call `timeout` that wins over the config default (#399).

Each upstream change is mapped to its Dart counterpart in `docs/agents/upstream-audit-solana_kit_helius-v3.5.0.md`.
