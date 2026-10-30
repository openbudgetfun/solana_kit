---
"solana_kit_helius": patch
---

# Track `helius-labs/helius-sdk` `v3.4.0`

The reference pin advances from `v3.3.0` to `v3.4.0`, with two behavioral fixes ported to the Dart port:

- `getAllTokenAccountsByOwner` now accepts both page shapes the endpoint returns: the flat shape (accounts and cursor at the top level, sent with `withContext`) and the value-wrapped shape (accounts under `value`, cursor as `paginationKey` next to it). The port previously parsed only the flat shape, which is not what the live endpoint returns by default.
- The DAS `HeliusAssetInterface` enum now uses the corrected `LEGACY_NFT` wire value and gains the `MplCoreGroup` and `MplBubblegumV2` interfaces (#373).

The remaining v3.4.0 changes are new surfaces (the parsed-events `scan` endpoint, `kitRpc` exposure, preconfirmation filters) and fixes to surfaces the Dart port does not implement; they are tracked for follow-up ports in `docs/agents/upstream-audit-solana_kit_helius-v3.4.0.md`.
