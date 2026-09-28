---
"solana_kit_surfpool": patch
---

# Redact credentials from Surfnet process output and exceptions

Forking a Surfnet from a paid RPC provider means passing an upstream URL such as `https://mainnet.helius-rpc.com/?api-key=...` through `SurfnetConfig.remoteRpcUrl`. When `surfpool start` timed out or logged its configuration, the credential-bearing URL was embedded verbatim in `SurfnetProcessException` messages, error contexts, and the drained event stream — and those routinely end up in application logs.

Captured process output and readiness-timeout exceptions now run through a credential redaction pass: query parameters such as `api-key`, `token`, or `password`, and `user:password@` userinfo, are replaced with `[REDACTED]` everywhere the URL appears. URLs without credentials are unchanged.
