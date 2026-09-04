---
"solana_kit_jupiter": patch
---

# Secure Jupiter transport and repair Swap v2 and Token v2 flows

Require HTTPS by default, reject credentials embedded in base URLs, and disable HTTP redirects so API keys and signed transactions cannot be forwarded to another origin. Explicitly trusted development endpoints can opt into HTTP with `allowInsecureHttp`.

Send the documented managed-execution payload, require an order request ID, expose execution status and result codes, and support the taker required to assemble swaps. Preserve Swap v2 lookup tables, additional and tip instructions, and blockhash metadata. Correct token-tag queries and category/interval paths, validate category inputs, and reject malformed price responses instead of treating them as empty markets.
