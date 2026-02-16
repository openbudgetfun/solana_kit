---
solana_kit_instruction_plans: minor
---

Implement instruction plans package ported from `@solana/instruction-plans`.

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
