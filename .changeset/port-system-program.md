---
default: minor
---

Port System Program from upstream Codama IDL

## codama-renderers-dart

- Fix instruction builder `programAddress` param collision when an instruction's data also has a `programAddress` field (e.g., System `Assign`, `CreateAccount`). The instruction-level program address is now named `instructionProgramAddress` when a collision exists.
- Fix BigInt-width size prefix types (u64/u128) in `sizePrefixTypeNode` by substituting u32 encoder/decoder, which satisfies the Dart `Encoder<num>` constraint.

## solana_kit_system

- Replace the handwritten `CreateAccount` helper with a fully generated client from `solana-program/system` Codama IDL (`js@v0.12.0`, commit `95897f3`).
- Includes all 13 System Program instructions, Nonce account type, NonceVersion/NonceState enums, 9 error codes, and program address constant.

## solana_kit_token

- Update `getCreateMintInstructionPlan` to use the renamed `instructionProgramAddress` parameter from the regenerated system instruction.

## solana_kit

- Re-export `solana_kit_system` with `systemProgramAddress` hidden to avoid conflict with `solana_kit_transaction_messages`.
