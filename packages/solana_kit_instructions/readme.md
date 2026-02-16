# solana_kit_instructions

Types and helpers for creating Solana transaction instructions.

This is the Dart port of [`@solana/instructions`](https://github.com/anza-xyz/kit/tree/main/packages/instructions) from the Solana TypeScript SDK.

## Installation

```yaml
dependencies:
  solana_kit_instructions:
```

Since this package is part of the `solana_kit` workspace, you can also use the umbrella package:

```yaml
dependencies:
  solana_kit:
```

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

| Function | Description |
| --- | --- |
| `isInstructionForProgram` | Returns `true` if the instruction targets the given program address. |
| `assertIsInstructionForProgram` | Throws `SolanaError` if the instruction does not target the given program. |
| `isInstructionWithAccounts` | Returns `true` if the instruction has an accounts list. |
| `assertIsInstructionWithAccounts` | Throws `SolanaError` if the instruction has no accounts. |
| `isInstructionWithData` | Returns `true` if the instruction has data. |
| `assertIsInstructionWithData` | Throws `SolanaError` if the instruction has no data. |
| `isSignerRole` | Returns `true` if the role represents a signer. |
| `isWritableRole` | Returns `true` if the role represents a writable account. |
| `upgradeRoleToSigner` | Returns the signer variant of the given role. |
| `upgradeRoleToWritable` | Returns the writable variant of the given role. |
| `downgradeRoleToNonSigner` | Returns the non-signer variant of the given role. |
| `downgradeRoleToReadonly` | Returns the read-only variant of the given role. |
| `mergeRoles` | Returns the role with the highest privileges of both inputs. |
