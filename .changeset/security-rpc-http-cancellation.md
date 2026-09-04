---
"solana_kit_rpc_transport_http": patch
"solana_kit_rpc": patch
---

# Honor RPC HTTP cancellation and protect credentials

Honor RPC cancellation signals while sending HTTP requests and streaming response bodies. Keep requests with cancellation signals independent so cancelling one caller cannot cancel another caller's request. Require `http` 1.5 or newer for native request abortion support.

Reject HTTP redirects without forwarding custom authentication headers to the redirect destination.

Prevent connection, cancellation, and response-stream HTTP exceptions from exposing credentials embedded in endpoint URLs or client error messages.
