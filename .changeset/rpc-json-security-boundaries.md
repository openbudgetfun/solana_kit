---
"solana_kit_rpc_spec_types": patch
---

# Harden RPC JSON integer boundaries

Preserve user JSON objects instead of interpreting `$n` fields as BigInt markers when parsing responses or serializing requests. Reject positive integer exponents above 10,000 before expansion to bound resource use from compact untrusted JSON, while preserving exact normal-range integers, strict JSON syntax, and cyclic-value errors.
