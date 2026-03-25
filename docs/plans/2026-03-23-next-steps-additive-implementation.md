# Next Steps Additive Implementation Plan

_Date:_ 2026-03-23\
_Worktree:_ `/Users/ifiokjr/Developer/projects/solana_kit-next-steps-20260323`\
_Branch:_ `feat/next-steps-plan-and-additive-apis`

## Goals

This iteration focuses on additive, non-breaking improvements that make the SDK easier to use and easier to maintain:

1. Add a higher-level transaction submission + confirmation API.
2. Close a small but visible generator gap in the Codama Dart renderer.
3. Add lightweight upstream compatibility drift checks.
4. Add an initial local benchmark harness.
5. Update docs and READMEs so the new workflows are discoverable.

## Constraints

- No breaking API changes.
- Keep existing lower-level primitives available.
- Add thorough tests around any new public behavior.
- Do the work in an isolated git worktree.

## Planned Changes

### 1. High-level confirmation ergonomics

Add additive helpers around the existing RPC + confirmation primitives:

- `Rpc.getEpochInfo()` typed convenience method in `solana_kit_rpc`.
- `waitForTransactionConfirmation(...)` in `solana_kit_transaction_confirmation`.
- `sendAndConfirmTransaction(...)` in `solana_kit_transaction_confirmation`.
- Polling-based confirmation internals built on existing RPC methods so callers get a simple happy-path API without losing access to lower-level strategy utilities.

Notes:

- The new API should work with both blockhash lifetimes and durable nonce lifetimes.
- The implementation should preserve the existing strategy-focused surface instead of replacing it.
- The new API should validate fully signed transactions before submission.

### 2. Upstream compatibility checks

Add a local/CI-friendly script that checks:

- the tracked `@solana/kit` version references are internally consistent across docs,
- the upstream clone is present or can be checked when available,
- newer upstream versions are surfaced as informational drift rather than silently ignored.

This iteration is intentionally lightweight and non-breaking: it should improve visibility without forcing an immediate upstream version jump.

### 3. Benchmark harness

Add deterministic local benchmarks for a few hot paths:

- address validation / coercion,
- transaction wire encoding,
- BigInt-aware JSON parsing.

The first version only needs reproducible local scripts plus documentation and a single command to run them.

### 4. Codama PDA renderer completion

Replace the remaining PDA generation placeholder with real generated code that calls `getProgramDerivedAddress(...)`.

## Test Plan

### Unit tests

Add tests for:

- `Rpc.getEpochInfo()` request wiring.
- successful blockhash-lifetime confirmation.
- block height expiry failure.
- successful durable nonce confirmation.
- durable nonce invalidation failure.
- send + confirm happy path.
- validation failures for unsigned or lifetime-less transactions.
- abort propagation for polling helpers.

### Renderer tests

Update Codama renderer tests to assert that generated PDA files now call `getProgramDerivedAddress(...)` instead of throwing `UnimplementedError`.

### Validation commands

Planned validation after implementation:

- `dart analyze`
- targeted Dart package tests
- `pnpm --filter codama-renderers-dart test`
- benchmark command smoke run
- upstream compatibility script run

## Non-goals for this iteration

- Full live-network integration tests against a validator/devnet.
- Full fixture-by-fixture upstream parity automation.
- MWA iOS implementation work.
- Subscription lifecycle redesign.

## Expected Deliverables

- additive public APIs for send/confirm flows,
- updated READMEs and docs,
- a local benchmark command,
- an upstream compatibility check command,
- Codama PDA generation no longer throwing `UnimplementedError`.

## Implementation Status

Completed in this worktree:

- Added `Rpc.getEpochInfo()` in `solana_kit_rpc` with request wiring tests.
- Added polling-based `waitForTransactionConfirmation(...)` and `sendAndConfirmTransaction(...)` helpers in `solana_kit_transaction_confirmation`.
- Added benchmark scripts under:
  - `packages/solana_kit_addresses/benchmark/address_benchmark.dart`
  - `packages/solana_kit_transactions/benchmark/wire_transaction_benchmark.dart`
  - `packages/solana_kit_rpc_spec_types/benchmark/json_bigint_benchmark.dart`
- Added `scripts/check-upstream-compatibility.sh` plus `upstream:check` and CI coverage.
- Completed Codama PDA rendering by generating real `getProgramDerivedAddress(...)` calls.
- Updated READMEs and site docs to explain the new workflows.

## Validation Status

Validated locally:

- `dart analyze .`
- `dart test packages/solana_kit_rpc`
- `dart test packages/solana_kit_transaction_confirmation`
- benchmark script smoke runs for addresses, transactions, and rpc-spec-types
- `pnpm typecheck` in `packages/codama-renderers-dart`
- `pnpm test` in `packages/codama-renderers-dart`
- `scripts/workspace-doc-drift.sh --check`
- `scripts/check-upstream-compatibility.sh` and `scripts/check-upstream-compatibility.sh --clone-if-missing`

Current upstream drift note observed during validation:

- local compatibility metadata is internally consistent at `@solana/kit` `6.5.0`,
- upstream `@solana/kit` is currently `6.5.0`, so parity work remains intentionally tracked rather than silently bumped.
