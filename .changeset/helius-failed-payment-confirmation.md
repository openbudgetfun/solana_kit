---
"solana_kit_helius": patch
---

# Reject failed Helius transaction confirmations

Reject failed on-chain transactions during transaction and bundle confirmation instead of returning successful results. Accept confirmed signatures when processed commitment is requested.

Redact API keys and URL credentials from JSON-RPC and REST connection exceptions, and omit URL credentials from WebSocket connection errors.
