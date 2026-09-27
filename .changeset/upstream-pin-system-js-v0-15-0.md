---
"solana_kit_system": patch
---

# Track `solana-program/system` `js@v0.15.0`

The reference pin moves from `js@v0.14.1` to `js@v0.15.0`. Upstream's release only bumps `@codama/renderers-js` and regenerates `clients/js/src/generated/**`, widening the generated TypeScript account inputs from `TransactionSigner<TAccount>` / `Address<TAccount>` to the `InstructionSignerInput` / `InstructionAccountInput` family, plus a `rustls` advisory bump.

This package generates from the repository's `idl.json`, not from the TypeScript client, and that file is byte-identical at both tags. Regenerating against the old and new pins produced byte-identical Dart, so **no generated code changes**. The published package contents are unchanged; the pin only records which upstream revision the clients were verified against.
