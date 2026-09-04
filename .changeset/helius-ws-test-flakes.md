---
"solana_kit_helius": patch
---

# Harden load-sensitive Helius websocket tests

Two Helius websocket tests failed on a loaded CI runner while passing locally: the connection-failure test raced the kernel completing handshakes queued before `HttpServer.close(force: true)` (so `connect()` occasionally succeeded instead of refusing), and the preconf websocket tests enforced 5-second timeouts that expired under load. The port-close test now probes the port until it provably refuses connections before asserting the failure path, and the preconf stream timeouts — which exist only to prevent hangs — are widened to 30 seconds.
