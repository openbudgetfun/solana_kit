---
"solana_kit_address_lookup_table": patch
---

# Track `solana-program/address-lookup-table` `js@v0.15.0`

The reference pin moves from `js@v0.14.1` to `js@v0.15.0`. Upstream's release bumps `@codama/renderers-js` and regenerates the TypeScript client, and separately bumps several Rust dependencies (`solana-instruction`, `solana-slot-hashes`, and `solana-bincode` to their 4.x lines) plus a `rustls` advisory fix.

This package generates from the repository's `idl.json`, not from the TypeScript or Rust clients, and that file is byte-identical at both tags. Regenerating against the old and new pins produced byte-identical Dart, so **no generated code changes**. The README now cites `js@v0.15.0` as the mirrored upstream version.
