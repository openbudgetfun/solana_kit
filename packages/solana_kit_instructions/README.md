# solana_kit_instructions

[![pub package](https://img.shields.io/pub/v/solana_kit_instructions.svg)](https://pub.dev/packages/solana_kit_instructions)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_instructions/latest/)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Types and helpers for creating Solana transaction instructions.

This is the Dart port of [`@solana/instructions`](https://github.com/anza-xyz/kit/tree/main/packages/instructions) from the Solana TypeScript SDK.

<!-- {=packageInstallSection:"solana_kit_instructions"} -->

## Installation

Install the package directly:

```bash
dart pub add solana_kit_instructions
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_instructions"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_instructions
- API reference: https://pub.dev/documentation/solana_kit_instructions/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_instructions
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_instructions

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Creating instructions

An `Instruction` describes a call to a Solana program. It includes the program address, an optional list of account metadata, and optional opaque data bytes.

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

// A simple instruction with no accounts or data.
final instruction = Instruction(
  programAddress: Address('11111111111111111111111111111111'),
);

// An instruction with accounts and data.
final transferInstruction = Instruction(
  programAddress: Address('11111111111111111111111111111111'),
  accounts: [
    AccountMeta(
      address: Address('mpngsFd4tmbUfzDYJayjKZwZcaR7aWb2793J6grLsGu'),
      role: AccountRole.writableSigner,
    ),
    AccountMeta(
      address: Address('GDhQoTpNbYUaCAjFKBMCPCdrCaKaLiSqhx5M7r4SrEFy'),
      role: AccountRole.writable,
    ),
  ],
  data: Uint8List.fromList([2, 0, 0, 0, 0, 202, 154, 59, 0, 0, 0, 0]),
);
```

### Account roles

Every account that participates in a transaction is assigned a role via `AccountRole`. Roles are encoded as a two-bit bitmask:

| Role             | Signer | Writable | Value |
| ---------------- | ------ | -------- | ----- |
| `readonly`       | No     | No       | 0b00  |
| `writable`       | No     | Yes      | 0b01  |
| `readonlySigner` | Yes    | No       | 0b10  |
| `writableSigner` | Yes    | Yes      | 0b11  |

```dart
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

// Check whether a role is a signer or writable.
final role = AccountRole.writableSigner;
print(isSignerRole(role));   // true
print(isWritableRole(role)); // true

// Upgrade / downgrade roles.
final upgraded = upgradeRoleToSigner(AccountRole.writable);
print(upgraded); // AccountRole.writableSigner

final downgraded = downgradeRoleToNonSigner(AccountRole.writableSigner);
print(downgraded); // AccountRole.writable

// Merge two roles, taking the highest privilege of each.
final merged = mergeRoles(AccountRole.readonlySigner, AccountRole.writable);
print(merged); // AccountRole.writableSigner
```

### Address lookup table accounts

For versioned transactions (v0), accounts can be referenced via address lookup tables. Use `AccountLookupMeta` for this:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

final lookupAccount = AccountLookupMeta(
  address: Address('GDhQoTpNbYUaCAjFKBMCPCdrCaKaLiSqhx5M7r4SrEFy'),
  addressIndex: 3,
  lookupTableAddress: Address('4wBqpZM9msxygPoFDEBSm7BKZRXBT6DzChAZ87UMVGim'),
  role: AccountRole.writable,
);

// AccountLookupMeta extends AccountMeta, so it fits anywhere
// an AccountMeta is accepted.
final instruction = Instruction(
  programAddress: Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
  accounts: [lookupAccount],
);
```

### Asserting instruction properties

The package provides guard functions that throw a `SolanaError` when an assertion fails:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

final systemProgram = Address('11111111111111111111111111111111');
final instruction = Instruction(programAddress: systemProgram);

// Returns true if the instruction targets the given program.
print(isInstructionForProgram(instruction, systemProgram)); // true

// Throws SolanaError if the program addresses do not match.
assertIsInstructionForProgram(instruction, systemProgram);

// Check that accounts or data are present.
print(isInstructionWithAccounts(instruction)); // false
print(isInstructionWithData(instruction));     // false

// These will throw because accounts and data are null.
// assertIsInstructionWithAccounts(instruction);
// assertIsInstructionWithData(instruction);
```

## API Reference

### Classes

- **`Instruction`** -- An instruction destined for a given program, with `programAddress`, optional `accounts`, and optional `data`.
- **`AccountMeta`** -- An account's address and its role in the transaction.
- **`AccountLookupMeta`** -- Extends `AccountMeta` with lookup table address and index for versioned transactions.

### Enums

- **`AccountRole`** -- `readonly`, `writable`, `readonlySigner`, `writableSigner`.

### Functions

| Function                          | Description                                                                |
| --------------------------------- | -------------------------------------------------------------------------- |
| `isInstructionForProgram`         | Returns `true` if the instruction targets the given program address.       |
| `assertIsInstructionForProgram`   | Throws `SolanaError` if the instruction does not target the given program. |
| `isInstructionWithAccounts`       | Returns `true` if the instruction has an accounts list.                    |
| `assertIsInstructionWithAccounts` | Throws `SolanaError` if the instruction has no accounts.                   |
| `isInstructionWithData`           | Returns `true` if the instruction has data.                                |
| `assertIsInstructionWithData`     | Throws `SolanaError` if the instruction has no data.                       |
| `isSignerRole`                    | Returns `true` if the role represents a signer.                            |
| `isWritableRole`                  | Returns `true` if the role represents a writable account.                  |
| `upgradeRoleToSigner`             | Returns the signer variant of the given role.                              |
| `upgradeRoleToWritable`           | Returns the writable variant of the given role.                            |
| `downgradeRoleToNonSigner`        | Returns the non-signer variant of the given role.                          |
| `downgradeRoleToReadonly`         | Returns the read-only variant of the given role.                           |
| `mergeRoles`                      | Returns the role with the highest privileges of both inputs.               |

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_instructions"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_instructions/solana_kit_instructions.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_instructions`.

- Import path: `package:solana_kit_instructions/solana_kit_instructions.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
