---
"solana_kit_rpc_api": minor
"solana_kit_rpc_transport_http": patch
"solana_kit_rpc": patch
"solana_kit_instruction_plans": minor
"solana_kit": minor
"codama-renderers-dart": patch
---

# Track @solana/kit v8.2.0

The workspace now tracks upstream `@solana/kit` v8.2.0 and the parity harness passes against it.

- New `getAgGenesisCert` RPC method returning the Alpenglow genesis certificate (or `null`), with allowed numeric keypaths that keep `blockId`, `bitmap`, and `signature` byte arrays as numbers while upcasting `slot` to `BigInt`.
- `isSolanaRequest` recognizes `getAgGenesisCert` and the previously missed `getTransactionsForAddress`.
- New `createTransactionPlanExecutorWithConcurrentLeaves` mirroring upstream: every leaf starts concurrently (including across sequential plans), a failed leaf does not cancel siblings, non-divisible sequential plans are supported, and the executor builds results from the shared callback contract — context stored on the mutable map is preserved on failures.

Reference pins refreshed to the latest upstream tags (compute-budget v0.18.1, memo v0.13.1, token v0.16.1, token-2022 v0.16.1, stake v0.9.1, address-lookup-table v0.14.1, system v0.14.1, loader-v3 v0.6.1 — all packaging-only upstream changes), and the Codama renderer dependencies moved to codama 1.10.2 / renderers-core 1.4.0.
