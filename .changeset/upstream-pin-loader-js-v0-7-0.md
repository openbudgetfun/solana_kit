---
"solana_kit_loader": patch
---

# Track `solana-program/loader-v3` `js@v0.7.0` and `loader-v4` commit `76f8ce27`

Both loader references move: `loader-v3` from `js@v0.6.1` to `js@v0.7.0`, and `loader-v4` from commit `5bb854db` to commit `76f8ce27` (upstream still publishes no tag for that program).

Each release only bumps `@codama/renderers-js` and regenerates the TypeScript client with the wider `InstructionSignerInput` / `InstructionAccountInput` types. Both `idl.json` files are byte-identical at the old and new revisions, and this package generates from those IDLs. Regenerating against the old and new pins produced byte-identical Dart, so **no generated code changes** — `solana_kit_loader` keeps serving both loader versions exactly as before.
