---
"solana_kit_helius": patch
---

# Redact credentials echoed in Helius error bodies

When a Helius endpoint returned an error, the response body was embedded verbatim into the thrown `SolanaError` context. Some proxies and gateways echo the request URL — `https://mainnet.helius-rpc.com/?api-key=...` for the RPC endpoints this package builds by default — back inside that body, which leaked the API key into whatever logged the error.

Error bodies from `RestClient` and `AdminClient` now pass through the same credential redaction used for URLs: `api-key`-style query parameters and userinfo are replaced with `[REDACTED]`. The regional sender endpoints are also documented as cleartext `http://` infrastructure so callers understand the exposure before choosing a non-default region.
