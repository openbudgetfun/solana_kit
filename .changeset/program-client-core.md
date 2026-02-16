---
solana_kit_program_client_core: minor
---

Implement program client core package ported from `@solana/program-client-core`.

**solana_kit_program_client_core** (31 tests):

- `InstructionWithByteDelta` mixin for tracking account storage size changes
- `ResolvedInstructionAccount` type for resolved instruction account values
- `getNonNullResolvedInstructionInput` null-safety validation with descriptive errors
- `getAddressFromResolvedInstructionAccount` extracts Address from Address/PDA/TransactionSigner
- `getResolvedInstructionAccountAsProgramDerivedAddress` validates and extracts PDA
- `getResolvedInstructionAccountAsTransactionSigner` validates and extracts TransactionSigner
- `getAccountMetaFactory` factory converting ResolvedInstructionAccount to AccountMeta with omitted/programId strategies
- `SelfFetchFunctions` augmenting codecs with fetch/fetchMaybe/fetchAll/fetchAllMaybe methods
- Stub for self-plan-and-send functions (pending instruction_plans implementation)
