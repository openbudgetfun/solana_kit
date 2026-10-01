---
"solana_kit_instruction_plans": minor
---

# Message packer helpers for custom packers

Ports the custom message packer helpers from `@solana/instruction-plans` v8.4.0 (#2073):

- `resolveMaxInstructionsPerTransaction` validates and resolves the configured instruction limit in one call (defaulting to 16, rejecting non-positive values and anything above the 64-instruction transaction format limit).
- `assertMessageCanAccommodateSize` asserts a message can grow to a next size within a byte limit, throwing `instructionPlansMessageCannotAccommodatePlan` with the required and free byte counts.
- `isMessagePackerErrorThatRequiresNewCandidate` identifies every error that tells the planner to open a new transaction message.
- Custom packers can refuse a message for any reason by throwing `instructionPlansMessageRejectedByPacker` with a `reason`; the transaction planner now treats that rejection like the existing capacity errors and opens a new candidate message instead of failing the plan.

The internal `maxInstructions` handling of the built-in linear and instruction-list packers and the transaction planner now routes through these helpers, and the planner resolves the limit once per invocation.

**Breaking:** the Dart-only helpers `resolveMaxInstructions` and `assertValidMaxInstructionsPerTransaction` are removed in favor of `resolveMaxInstructionsPerTransaction`, which validates and resolves in one call — matching upstream, which never exported the two-function form. The realloc packer was also rewritten to chunk `totalSize` in a loop, matching upstream v8.4.0 (#2071); its output is unchanged (no 0-byte instruction for exact multiples of the 10,240-byte limit, which this port already guaranteed).
