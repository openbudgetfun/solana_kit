# solana_kit_system

[![pub package](https://img.shields.io/pub/v/solana_kit_system.svg)](https://pub.dev/packages/solana_kit_system)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_system)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_system)

Generated Dart client for the Solana System Program, part of the
[Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides typed instruction builders, account decoders, error definitions,
PDA helpers, and program address constants for all 13 System Program
instructions. Generated from the upstream Codama IDL at
[solana-program/system](https://github.com/solana-program/system)
(`js@v0.12.0`).

## Installation

```yaml
dependencies:
  solana_kit_system: ^0.3.2
```

## Usage

```dart
import 'package:solana_kit_system/solana_kit_system.dart';

// Create a new account
final ix = getCreateAccountInstruction(
  programAddress: systemProgramAddress,
  fromPubkey: payer,
  newAccountPubkey: newAccount,
  lamports: BigInt.from(10000000),
  space: BigInt.from(165),
  owner: tokenProgramAddress,
);

// Transfer SOL
final transferIx = getTransferSolInstruction(
  programAddress: systemProgramAddress,
  source: payer,
  destination: recipient,
  amount: BigInt.from(1000000),
);

// Derive a system account PDA
final pda = findCreateAccountWithSeedPda(
  base: baseAddress,
  seed: 'my-seed',
  owner: systemProgramAddress,
);
```

## Instructions

| Instruction              | Discriminator | Description                                             |
| ------------------------ | ------------- | ------------------------------------------------------- |
| `CreateAccount`          | 0             | Create a new account with the given space and owner.    |
| `Assign`                 | 1             | Assign an account to a program.                         |
| `TransferSol`            | 2             | Transfer lamports between accounts.                     |
| `CreateAccountWithSeed`  | 3             | Create an account derived from a base address and seed. |
| `AdvanceNonceAccount`    | 4             | Advance the nonce value in a nonce account.             |
| `WithdrawNonceAccount`   | 5             | Withdraw lamports from a nonce account.                 |
| `InitializeNonceAccount` | 6             | Initialize a nonce account with an authority.           |
| `AuthorizeNonceAccount`  | 7             | Change the authority of a nonce account.                |
| `Allocate`               | 8             | Allocate space for an account.                          |
| `AllocateWithSeed`       | 9             | Allocate space using a derived seed.                    |
| `AssignWithSeed`         | 10            | Assign an account to a program using a derived seed.    |
| `TransferSolWithSeed`    | 11            | Transfer lamports using a derived source address.       |
| `UpgradeNonceAccount`    | 12            | Upgrade a nonce account to a versioned format.          |

## Accounts

- **`Nonce`** — Nonce account data including authority, nonce value, and fee calculator.

## Types

- **`NonceState`** — Enum for nonce account state (`uninitialized`, `initialized`, `ready`).
- **`NonceVersion`** — Enum for nonce account version (`legacy`, `current`).

## Errors

Nine typed error codes covering invalid nonce state, missing accounts,
insufficient funds, and other System Program failure modes.

## Upstream reference

Generated layer mirrors
[solana-program/system](https://github.com/solana-program/system) at
`js@v0.12.0` (commit `95897f3`).
