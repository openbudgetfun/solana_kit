---
"solana_kit_surfpool": patch
---

# Validate Surfpool responses

Reject malformed or mismatched JSON-RPC response envelopes instead of reporting cheatcode mutations as successful. Bound stalled startup health checks by the configured startup timeout so failed readiness triggers process cleanup.

Preserve the optional tag position when profiling a transaction with configuration only, and unwrap cheatcode context envelopes to return their documented values.
