---
solana_kit_rpc_transport_http: minor
---

Implement RPC transport HTTP package ported from `@solana/rpc-transport-http`.

**solana_kit_rpc_transport_http** (129 tests):

- `createHttpTransport` factory for JSON-RPC POST requests with configurable headers, custom JSON serialization/deserialization
- `createHttpTransportForSolanaRpc` wrapping transport with BigInt-aware JSON handling via `parseJsonWithBigInts`/`stringifyJsonWithBigInts`
- `isSolanaRequest` type guard checking against 55 known Solana RPC methods
- Header validation: forbidden headers (MDN spec), disallowed headers (Accept, Content-Type, Content-Length, Solana-Client), proxy-\_/sec-\_ prefix matching
- HTTP error handling with `SolanaError` context preservation (status code, message)
