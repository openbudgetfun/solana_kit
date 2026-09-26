---
"solana_kit_token_2022": patch
---

# Track `solana-program/token-2022` `js@v0.19.0`

The reference pin moves from `js@v0.18.0` to `js@v0.19.0`. The release carries dependency bumps and a `@codama/renderers-js` bump that regenerates `clients/js/src/generated/**` with the wider `InstructionSignerInput` / `InstructionAccountInput` TypeScript types; the program's own test harness moved from `serial_test` to `mollusk`.

This package generates from the repository's `idl.json`, and that file is byte-identical at both tags — no instruction, account, extension, or wire-format change. Regenerating against the old and new pins produced byte-identical Dart, so **no generated code changes**. The README now cites `js@v0.19.0` as the mirrored upstream version.
