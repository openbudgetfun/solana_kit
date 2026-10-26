---
"solana_kit_helius": patch
---

# URL-encode dynamic path segments in REST endpoints

Dynamic path segments in the REST endpoints (`projectId`, `webhookId`, `address`, `wallet`, `stakeAccount`) are now URL-encoded, so a value returned by a compromised API cannot reshape a subsequent request's path on the Helius host. Fixed paths and the API-key query parameter are unchanged.
