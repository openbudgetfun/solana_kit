# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_system [0.3.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_system/v0.3.2) (2026-05-28)

### 🚀 Feature

#### Port System Program from upstream Codama IDL

##### codama-renderers-dart

- Fix instruction builder `programAddress` param collision when an instruction's data also has a `programAddress` field (e.g., System `Assign`, `CreateAccount`). The instruction-level program address is now named `instructionProgramAddress` when a collision exists.
- Fix BigInt-width size prefix types (u64/u128) in `sizePrefixTypeNode` by substituting u32 encoder/decoder, which satisfies the Dart `Encoder<num>` constraint.

##### solana_kit_system

- Replace the handwritten `CreateAccount` helper with a fully generated client from `solana-program/system` Codama IDL (`js@v0.12.0`, commit `95897f3`).
- Includes all 13 System Program instructions, Nonce account type, NonceVersion/NonceState enums, 9 error codes, and program address constant.

##### solana_kit_token

- Update `getCreateMintInstructionPlan` to use the renamed `instructionProgramAddress` parameter from the regenerated system instruction.

##### solana_kit

- Re-export `solana_kit_system` with `systemProgramAddress` hidden to avoid conflict with `solana_kit_transaction_messages`.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`1eaf898`](https://github.com/openbudgetfun/solana_kit/commit/1eaf898cd0598744731152e8841dc632fc2e69f9) · _Last updated in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)

#### Detached from main group

This package is now released independently rather than as part of the main solana_kit group. The System Program client is a standalone program package that does not depend on the core solana_kit release cycle, so an independent release track is more appropriate.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`3c175c3`](https://github.com/openbudgetfun/solana_kit/commit/3c175c3a852f04df89145f1edc5c458abaab253d)

### 🐛 Fixed

#### Add comprehensive generated-code test coverage for solana_kit_token (instructions, accounts, types, PDAs) and solana_kit_system (codec round-trips, parse round-trip, program constants).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`d930a56`](https://github.com/openbudgetfun/solana_kit/commit/d930a56035d5e4a34121be2a4d9ffcd30c0ad592) · _Last updated in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)
