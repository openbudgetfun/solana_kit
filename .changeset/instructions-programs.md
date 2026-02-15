---
solana_kit_instructions: minor
solana_kit_programs: minor
---

Implement instructions and programs packages ported from `@solana/instructions` and `@solana/programs`.

**solana_kit_instructions** (56 tests):

- `AccountRole` enhanced enum with bitflag values (readonly, writable, readonlySigner, writableSigner)
- 7 role manipulation functions: upgrade/downgrade signer/writable, merge, query
- `AccountMeta` and `AccountLookupMeta` immutable classes with const constructors
- `Instruction` class with optional accounts and data fields
- 6 instruction validation functions: isInstructionForProgram, isInstructionWithAccounts, isInstructionWithData (with assert variants)

**solana_kit_programs** (5 tests):

- `isProgramError` function to identify custom program errors from transaction failures
- Matches error code, instruction index, and program address against transaction message
- `TransactionMessageInput` and `InstructionInput` minimal types for error checking
