# Changelog

All notable changes to this package will be documented in this file.

## 0.2.0 (2026-02-27)

### Breaking Changes

#### Initial Release

The initial release of all libraries.

### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for program and transaction planning packages.
- Document fix: resolve fatal analyzer infos across workspace.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

## 0.1.0 (2026-02-21)

### Notes

- First 0.1.0 release of this package.

## 0.0.2 (2026-02-21)

### Features

#### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct
workspace dependencies, shared analysis_options.yaml, and an empty barrel export
file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec),
  fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages,
  transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

#### Implement instruction plans package ported from `@solana/instruction-plans`.

**solana_kit_instruction_plans** (215 tests):

- `InstructionPlan` sealed class hierarchy: `SingleInstructionPlan`, `SequentialInstructionPlan`, `ParallelInstructionPlan`, `MessagePackerInstructionPlan`
- `TransactionPlan` sealed class hierarchy: `SingleTransactionPlan`, `SequentialTransactionPlan`, `ParallelTransactionPlan`
- `TransactionPlanResult` sealed class hierarchy with successful, failed, canceled, sequential, and parallel result types
- `createTransactionPlanner` converting instruction plans to transaction plans with size-aware message packing
- `createTransactionPlanExecutor` for executing transaction plans with context propagation
- `MessagePacker` with linear, instruction-based, and realloc message packer factories
- Tree traversal utilities: `findInstructionPlan`, `everyInstructionPlan`, `transformInstructionPlan`, `flattenTransactionPlan`
- Type guards and assertions for all plan types
- `appendTransactionMessageInstructionPlan` helper for adding instructions to messages
- `passthroughFailedTransactionPlanExecution` for error handling passthrough
- `TransactionPlanResultSummary` with `summarizeTransactionPlanResult` for result aggregation
