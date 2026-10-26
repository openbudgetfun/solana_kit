---
"solana_kit_jupiter": patch
---

# Reject insecure HTTP Jupiter endpoints in release builds

`JupiterConfig`'s `allowInsecureHttp` flag worked in release builds, unlike the core HTTP and WebSocket transports, which reject `http://` in product mode regardless of the flag — so a development-only flag could ship and send the `x-api-key` header and swap traffic in cleartext. The flag is now ignored in release (product) builds and `https://` is always required, matching the core transports and the documented security posture.
