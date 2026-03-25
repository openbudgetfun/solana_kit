---
default: patch
---

Port `@solana/kit` `v6.1.0` parity updates for predicate codecs and
transaction encoding behavior.

- Add `getPredicateEncoder`, `getPredicateDecoder`, and `getPredicateCodec`.
- Add v1 message-first transaction encoding with fixed-length signatures.
- Add transaction malformed message bytes error parity (`5663023`).
