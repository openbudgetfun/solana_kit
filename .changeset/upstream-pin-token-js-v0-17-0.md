---
"solana_kit_token": patch
---

# Track `solana-program/token` `js@v0.17.0`

The reference pin moves from `js@v0.16.1` to `js@v0.17.0`. Upstream's release only bumps `@codama/renderers-js` and regenerates `clients/js/src/generated/**`, widening the generated TypeScript account inputs from `TransactionSigner<TAccount>` / `Address<TAccount>` to the `InstructionSignerInput` / `InstructionAccountInput` family.

This package generates from the repository's `idl.json`, not from the TypeScript client, and that file is byte-identical at both tags. Regenerating against the old and new pins produced byte-identical Dart, so **no generated code changes** — no instruction, account, type, or wire-format difference. The README now cites `js@v0.17.0` as the mirrored upstream version.
