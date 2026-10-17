# Upstream audit — helius-labs/helius-sdk v3.2.0 → v3.3.0

`helius-sdk` v3.3.0 was published on 2026-10-14. This note maps every change in that release to its Dart counterpart, including the items that are deliberately not ported, so the compatibility claim can be audited.

Status: the workspace tracks `v3.3.0` (`checkedCommit 1a37d6f0d9eb`); `clone:repos:status` verifies the pin.

## Upstream changes

| Commit                                                                                          | Change                                                                                                                                                                            |
| ----------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `6e63a6b` feat(ws): add parsed streams client (#358)                                            | New `parsedStreams` WebSocket client (~800 lines + 950 lines of tests): a streaming variant of the parsed transaction events API over WebSockets.                                 |
| `dcaa27d` feat(parsed-events): add parsed events api and deprecate enhanced transactions (#356) | New `parsedEvents` REST API (`parseTransactions`, `getTransactionHistory`, types, utils — ~700 lines + 400 lines of tests); the existing enhanced-transactions API is deprecated. |
| `1cea88d` add preconfirmation filters and getPreConfCoverage (#363)                             | Preconfirmation WebSocket API expansion: subscription filters and a coverage RPC; substantial rework of `preconfWs.ts` (~740 changed lines).                                      |
| `858f813` add mev protect support (#357)                                                        | MEV-protect sending support in the sender transaction helpers.                                                                                                                    |
| `23483d6`, `06b292f` auth fixes                                                                 | Signup contact-info validation, wallet project creation deprecated, autoscaling wording in `purchaseCredits`.                                                                     |
| `c47a16a` fix(enhanced): handle non-JSON error bodies (#360)                                    | Enhanced-API error handling falls back to the raw body text when the error body is not JSON (e.g. a gateway HTML page).                                                           |
| `a7a4466` fix(websockets): reject a waiting iterator when the connection drops (#362)           | The hand-rolled async iterator now rejects a pending `next()` on connection loss instead of hanging.                                                                              |
| `76424a9` fix(rpc): append query params with `&` when baseUrl already has a query (#352)        | Custom `baseUrl`s carrying a query string no longer produce a doubled `?`; URL built with the `URL` API in a shared helper.                                                       |
| `a2d3447`, `e793e70` dependency patches                                                         | axios, brace-extension, markdown-it, js-yaml, browserlist, baseline-browser-mapping.                                                                                              |

## Dart impact

**The three upstream `fix` commits are already equivalent in the Dart port:**

- **Non-JSON error bodies (#360):** `RestClient._handleResponse` never JSON-parses error responses — it surfaces the redacted raw body (falling back to the HTTP reason phrase), so gateway HTML pages already appear verbatim in the thrown `heliusRestError`.
- **Waiting-iterator rejection (#362):** the Dart WebSocket client terminates each subscription's `StreamController` on connection loss, so an awaiting `StreamIterator` ends promptly instead of hanging — the bug upstream fixed cannot occur in the controller-based Dart design.
- **Query-parameter separator (#352):** the Dart `HeliusConfig` builds fixed per-cluster URLs and does not support custom base URLs, so the doubled-`?` path does not exist.

The feature areas are **not ported yet** — each is a self-contained new surface, tracked below.

## Not ported yet

| Upstream change                                                          | Why deferred                                                                                                                                                                                                                                                                                                         |
| ------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Parsed-events REST API (#356) and parsed-streams WebSocket client (#358) | Two whole new API surfaces (~1,500 lines of source plus types and tests). Porting them means new client classes, request/response types, and WebSocket subscription plumbing — each reviewable on its own; the port's existing enhanced-transactions API keeps working (upstream deprecates but does not remove it). |
| Preconfirmation filters and coverage RPC (#363)                          | An expansion of the preconfirmation WebSocket surface; the Dart `preconf_ws.dart` covers the base subscription API only.                                                                                                                                                                                             |
| MEV-protect support (#357)                                               | New sending mode in the sender transaction helpers.                                                                                                                                                                                                                                                                  |
| Auth API changes (#359, #353)                                            | Signup validation, wallet-project deprecation, and error-wording changes to surfaces the Dart `auth` client models differently; no behavioral fix, deprecation-only upstream.                                                                                                                                        |

## Reference pin

`config/reference-repos.json` advanced `helius-sdk` from tag `v3.2.0` (`checkedCommit b76a792979dc`) to tag `v3.3.0` (`checkedCommit 1a37d6f0d9eb`).
