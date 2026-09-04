---
"solana_kit_wallet_adapter": patch
---

# Validate mobile wallet request and authorization boundaries

Reject mobile wallet signing batches that mix authorized accounts, transaction chains, or submission options before calling the wallet backend. This prevents later requests from silently using the first account or submission policy and prevents transactions requested for another chain from using the active authorization.

Revoke local mobile wallet authority as soon as disconnect starts, including when backend cleanup fails, and prevent pending or superseded connect and sign-in requests from restoring authorization.
