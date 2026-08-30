# solana_kit_instructions

[![pub package](https://img.shields.io/pub/v/solana_kit_instructions.svg)](https://pub.dev/packages/solana_kit_instructions) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_instructions/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_instructions) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_instructions)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_instructions)

Types and helpers for creating Solana transaction instructions: `Instruction`, `AccountMeta`, `AccountLookupMeta`, and `AccountRole`.

<!-- {=packageInstallSection:"solana_kit_instructions"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_instructions": ^0.9.0
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

<!-- {=docsInstructionPrimitivesSection} -->

## Model an instruction

Use `Instruction` plus `AccountMeta` when you need to describe a program call before building a full transaction message around it.

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

void main() {
  const programAddress = Address('11111111111111111111111111111111');
  const signerAddress = Address('11111111111111111111111111111111');

  final instruction = Instruction(
    programAddress: programAddress,
    accounts: const [
      AccountMeta(
        address: signerAddress,
        role: AccountRole.writableSigner,
      ),
    ],
    data: Uint8List(0),
  );

  print(isInstructionForProgram(instruction, programAddress));
}
```

Keeping instruction construction explicit makes it easier to reason about required signer privileges, writable accounts, and serialized program data.

<!-- {/docsInstructionPrimitivesSection} -->

## Usage

### Account roles

`AccountRole` is a bitflag enum. Each role encodes whether the account signs the transaction and whether it is writable:

| Role             | isSigner | isWritable | Value |
| ---------------- | -------- | ---------- | ----- |
| `readonly`       | No       | No         | 0b00  |
| `writable`       | No       | Yes        | 0b01  |
| `readonlySigner` | Yes      | No         | 0b10  |
| `writableSigner` | Yes      | Yes        | 0b11  |

Helper functions modify roles without touching bitflags directly:

```dart
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

void main() {
  // Upgrade a readonly account to a signer.
  final signer = upgradeRoleToSigner(AccountRole.readonly);
  print(signer); // AccountRole.readonlySigner

  // Downgrade a writable signer to readonly.
  final downgraded = downgradeRoleToReadonly(AccountRole.writableSigner);
  print(downgraded); // AccountRole.readonlySigner

  // Merge two roles (takes the higher privilege of each).
  final merged = mergeRoles(AccountRole.readonlySigner, AccountRole.writable);
  print(merged); // AccountRole.writableSigner
}
```

### Guard and assertion functions

Several top-level functions test instruction properties. The `assertIs*` variants throw `SolanaError` on mismatch instead of returning `bool`.

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

void main() {
  final ix = Instruction(
    programAddress: const Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
    accounts: const [
      AccountMeta(address: Address('...'), role: AccountRole.writableSigner),
    ],
    data: Uint8List(0),
  );

  isInstructionForProgram(ix, const Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA')); // true
  isInstructionWithAccounts(ix); // true
  isInstructionWithData(ix); // true (empty data counts)
}
```

### Account lookup metadata

`AccountLookupMeta` extends `AccountMeta` with `addressIndex` and `lookupTableAddress` for v0 transactions that use address lookup tables. It can appear anywhere an `AccountMeta` is expected.

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
