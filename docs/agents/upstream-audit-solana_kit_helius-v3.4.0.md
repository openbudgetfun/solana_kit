# Upstream audit — helius-labs/helius-sdk v3.3.0 → v3.4.0

`helius-sdk` v3.4.0 was published with ~2,500 lines of changes. This note maps every change to its Dart counterpart, including the items deliberately not ported, so the compatibility claim can be audited.

Status: the workspace tracks `v3.4.0` (`checkedCommit 87cb392f0e69`); `clone:repos:status` verifies the pin.

## Ported

| Upstream change                                                 | Dart counterpart                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| --------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `getAllTokenAccountsByOwner` reads the page from `value` (#380) | `GetTokenAccountsByOwnerV2Response.fromJson` now accepts both page shapes: the flat result (accounts and cursor at the top level, sent with `withContext`) and the value-wrapped default (accounts under `value`, cursor as `paginationKey`). The port previously parsed only the flat shape, which the live endpoint does not return by default — pagination would have thrown on the wrapped shape. Covered by a two-page wrapped-shape pagination test. |
| DAS `Interface` enum values corrected and extended (#373)       | `HeliusAssetInterface.legacyNft` wire value corrected from `Legacy_NFT` to `LEGACY_NFT`, and the `MplCoreGroup` / `MplBubblegumV2` interfaces added to the enum and its `fromJson` switch, with round-trip tests.                                                                                                                                                                                                                                          |

## Already equivalent

| Upstream change                                                                                     | Why there is nothing to port                                                                                                                                          |
| --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Typed `HeliusRpcError` and null results returned as-is (#375)                                       | The Dart `json_rpc_client` already returns `json['result']` as-is (null included) and throws the typed `heliusRpcError` with the server's message on JSON-RPC errors. |
| Waiting-iterator rejection on connection drop (#362-era iterator behavior, further tests in v3.4.0) | The controller-based Dart WebSocket design ends awaiting iterators when the connection drops.                                                                         |

## Not ported yet

| Upstream change                                                                                | Why deferred                                                                                                                                                                       |
| ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Parsed-events `scan` endpoint (#379) and the parsed-events / parsed-streams surfaces generally | New API surfaces, deferred since v3.3.0; each deserves its own reviewable PR.                                                                                                      |
| `kitRpc` exposure (#377)                                                                       | New surface exposing the unwrapped `@solana/kit` RPC through the Helius client.                                                                                                    |
| Preconfirmation filters and coverage RPC (#363, expanded in v3.4.0)                            | The Dart `preconf_ws.dart` covers the base subscription API only.                                                                                                                  |
| MEV-protect support (#357)                                                                     | New sending mode.                                                                                                                                                                  |
| `filters.tokenTransfer` for `getTransactionsForAddress` (#381)                                 | Additive extension of the request `filters` structure, which the Dart `GetTransactionsForAddressRequest` does not model at all yet — the whole filters surface needs its own port. |
| Broadcast expiry re-check (#368)                                                               | The Dart `broadcast_transaction.dart` does not implement the poll/expiry loop the fix adjusts.                                                                                     |
| Enhanced devnet baseUrl selection (#370)                                                       | The Dart `HeliusConfig` already routes the devnet cluster to `api-devnet.helius.xyz` explicitly.                                                                                   |
| Lazy-namespace fixes (#378)                                                                    | JavaScript lazy-loading mechanics; the Dart port has no lazy namespaces.                                                                                                           |
| Staking bigint constants (#372)                                                                | The Dart staking client does not define the affected constants.                                                                                                                    |

## Reference pin

`config/reference-repos.json` advanced `helius-sdk` from tag `v3.3.0` (`checkedCommit 1a37d6f0d9eb`) to tag `v3.4.0` (`checkedCommit 87cb392f0e69`).
