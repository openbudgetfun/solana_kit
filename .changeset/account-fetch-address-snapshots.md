---
"solana_kit_accounts": patch
---

# Preserve account identities during batch fetches

Snapshot requested addresses before sending batch account requests, so changing the input list while the request is pending cannot attach returned account data to a different address or discard requested results. This applies to both encoded and JSON-parsed account fetches.
