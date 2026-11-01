---
"solana_kit_helius": minor
---

# Track `helius-labs/helius-sdk` `v3.4.0`

The reference pin advances from `v3.3.0` to `v3.4.0`, and the previously deferred v3 surfaces are ported:

- **Parsed Events REST API** — `helius.parsedEvents` exposes `parseTransactions`, `getTransactionHistory`, and the new `scan` endpoint, with typed requests/responses, manual pagination, program/instruction/mint match filters, and a mainnet-only guard.
- **Parsed Streams WebSocket client** — `helius.parsedStreams` subscribes to decoded transactions with program/instruction/account-role filters and `full`/`matched`/`raw` details, reconnects and resubscribes automatically, reports the last delivered slot, and exposes `describeProgram`.
- **Preconfirmation filters, slot events, and coverage** — `preconfSubscribe` accepts server-side filters and `{slots: true}`, slot bank lifecycle frames decode as `PreconfSlotNotification`, and `getPreConfCoverage` reads the HTTPS coverage endpoint. Each subscription now uses its own connection, matching the upstream design.
- **`kitRpc` and MEV Protect** — `HeliusClient.kitRpc` exposes a standard `solana_kit_rpc` client over the Helius transport, and `HeliusConfig.mevProtect` (plus per-call Sender overrides) appends `mev-protect=true`.
- **Broadcast expiry re-check** — `broadcastTransaction` now polls to landing with an expiry derived from the latest blockhash and chain height, performing one final status read after the expiry height before throwing.
- **`getTransactionsForAddress` filters** — the request models the full v3 filter surface, including `filters.tokenTransfer`, and responses parse the live `{data, paginationToken}` shape.
- **DAS fixes** — `getAllTokenAccountsByOwner` accepts both page shapes, and the DAS `HeliusAssetInterface` enum uses the corrected `LEGACY_NFT` wire value with `MplCoreGroup` and `MplBubblegumV2`.
- **Staking constants** — `stakingU64Max` and `lamportsPerSolBigInt` expose the upstream `BigInt` constants.

The changeset is minor because the new clients and request fields are additive, while `GetTransactionsForAddressRequest` moves from the inaccurate `before`/`until` fields to the upstream `paginationToken` and `filters` shape.
