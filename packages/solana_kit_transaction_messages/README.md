# solana_kit_transaction_messages

[![pub package](https://img.shields.io/pub/v/solana_kit_transaction_messages.svg)](https://pub.dev/packages/solana_kit_transaction_messages) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_transaction_messages/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_transaction_messages) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_transaction_messages)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_transaction_messages)

Build, compile, and decompile Solana transaction messages. Create an empty message, set a fee payer and lifetime, append instructions, then compile it for signing.

<!-- {=packageInstallSection:"solana_kit_transaction_messages"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_transaction_messages": ^0.8.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_transaction_messages"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_transaction_messages
- API reference: https://pub.dev/documentation/solana_kit_transaction_messages/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_transaction_messages
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_transaction_messages

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

Transaction messages are assembled incrementally. Create an empty message, set the fee payer, set a lifetime constraint using a recent blockhash, and append one or more instructions.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

void main() {
  final message = createTransactionMessage(version: TransactionVersion.v0)
      .withFeePayer(const Address('11111111111111111111111111111111'))
      .withBlockhashLifetime(
        BlockhashLifetimeConstraint(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
      );

  print(message.feePayer);
}
```

This separation keeps transaction construction explicit and makes it easier to reason about fee payment, expiry, and instruction ordering. The `.withFeePayer()`, `.withBlockhashLifetime()`, and `.appendInstruction()` extension methods build on the same underlying model as the standalone functions `setTransactionMessageFeePayer`, `setTransactionMessageLifetimeUsingBlockhash`, and `appendTransactionMessageInstruction`.

### Compile for signing

Once a message has a fee payer, lifetime, and instructions, compile it into the wire-ready format that signers and senders consume.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

void main() {
  final message = createTransactionMessage(version: TransactionVersion.v0)
      .withFeePayer(const Address('11111111111111111111111111111111'))
      .withBlockhashLifetime(
        BlockhashLifetimeConstraint(
          blockhash: '11111111111111111111111111111111',
          lastValidBlockHeight: BigInt.zero,
        ),
      );

  final compiled = compileTransactionMessage(message);
  print(compiled.header.numSignerAccounts);
}
```

Compilation is lossy: you cannot fully reconstruct a source message from a compiled message without extra information.

### Pipe extension

The `Pipe<T>` extension adds a `.pipe()` method to every Dart value, enabling fluent left-to-right pipeline composition. This is the same extension previously exported from `solana_kit_functional` (now deprecated).

```dart
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

void main() {
  final result = 'hello'
      .pipe((v) => v.toUpperCase())
      .pipe((v) => '$v!');
  print(result); // HELLO!
}
```

## API reference

### Message construction

- `createTransactionMessage({required TransactionVersion version})` creates an empty message.
- `setTransactionMessageFeePayer(Address, TransactionMessage)` returns a copy with the fee payer set.
- `setTransactionMessageLifetimeUsingBlockhash(String, TransactionMessage)` returns a copy with a blockhash lifetime.
- `appendTransactionMessageInstruction(Instruction, TransactionMessage)` returns a copy with the instruction appended.
- `appendTransactionMessageInstructions(List<Instruction>, TransactionMessage)` returns a copy with multiple instructions appended.

### Fluent extension methods

These wrap the standalone functions above for method-chaining style:

- `.withFeePayer(Address)`
- `.withBlockhashLifetime(BlockhashLifetimeConstraint)`
- `.appendInstruction(Instruction)`
- `.appendInstructions(List<Instruction>)`

### Compilation and decompilation

- `compileTransactionMessage(TransactionMessage)` compiles a message for signing.
- `decompileMessage(CompiledTransactionMessage)` reverses compilation back to a `TransactionMessage`.

### Pipe

- `Pipe<T>` on `T` adds `R pipe<R>(R Function(T) transform)`.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_transaction_messages"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_transaction_messages`.

- Import path: `package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
