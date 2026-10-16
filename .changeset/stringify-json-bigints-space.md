---
"solana_kit_rpc_spec_types": patch
---

# Implement the space argument of stringifyJsonWithBigInts

`stringifyJsonWithBigInts` accepted a `space` parameter named after `JSON.stringify`'s but silently ignored it, so callers asking for pretty-printed output always got compact JSON with no error. The parameter now works exactly like its upstream counterpart: an int indents by that many spaces (clamped to ten, zero or negative stays compact) and a string is repeated at each nesting level (first ten characters), with `": "` separators and the same newline placement as `JSON.stringify`. Compact output — the default used by the RPC transports — is byte-for-byte unchanged.
