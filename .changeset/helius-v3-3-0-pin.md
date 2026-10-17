---
"solana_kit_helius": patch
---

# Track `helius-labs/helius-sdk` `v3.3.0`

The reference pin advances from `v3.2.0` to `v3.3.0`. The upstream release adds two new API surfaces (the parsed-events REST API and the parsed-streams WebSocket client), expands the preconfirmation WebSocket API, and fixes three bugs whose Dart counterparts are already equivalent: the Dart REST client surfaces raw non-JSON error bodies verbatim, the controller-based WebSocket client ends awaiting iterators on connection loss instead of hanging, and `HeliusConfig` builds fixed per-cluster URLs so the doubled-query-separator bug cannot occur. No code the Dart port implements changed. The new API surfaces are tracked for follow-up ports; see `docs/agents/upstream-audit-solana_kit_helius-v3.3.0.md`.
