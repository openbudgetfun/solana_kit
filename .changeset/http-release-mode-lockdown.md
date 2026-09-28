---
"solana_kit_rpc_transport_http": patch
---

# Lock insecure HTTP endpoints out of release builds

`allowInsecureHttp: true` unconditionally permitted `http://` endpoints in every build mode. A Flutter app that flipped the flag for local development and shipped that configuration got plaintext RPC in production — with API keys in headers traveling in cleartext.

The HTTP transport now mirrors the WebSocket transport's release-mode lockdown: in release and profile builds (`dart.vm.product`), `http://` endpoints are rejected with an `ArgumentError` regardless of `allowInsecureHttp`, while debug builds keep the escape hatch for local development.
