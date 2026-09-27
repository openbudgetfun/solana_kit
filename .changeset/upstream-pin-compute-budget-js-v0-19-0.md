---
"solana_kit_compute_budget": patch
---

# Track `solana-program/compute-budget` `js@v0.19.0`

The reference pin moves from `js@v0.18.1` to `js@v0.19.0`. Upstream's release only bumps `@codama/renderers-js` and regenerates the clients.

This package generates from the repository's `idl.json`, and that file is byte-identical at both tags. Regenerating against the old and new pins produced byte-identical Dart, so **no generated code changes** — every compute-unit limit, price, and heap-frame instruction is unchanged. The README now cites `js@v0.19.0` as the mirrored upstream version.
