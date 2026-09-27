---
"solana_kit_memo": patch
---

# Track `solana-program/memo` `js@v0.15.0`

The reference pin moves from `js@v0.14.1` to `js@v0.15.0`. Upstream's release only bumps `codama` and regenerates the clients, widening the generated TypeScript inputs to the `InstructionSignerInput` / `InstructionAccountInput` family.

This package generates from the repository's `idl.json`, and that file is byte-identical at both tags. Regenerating against the old and new pins produced byte-identical Dart, so **no generated code changes** — the v4 program address and the memo extraction helpers behave exactly as before. The README now cites `js@v0.15.0` as the mirrored upstream version.
