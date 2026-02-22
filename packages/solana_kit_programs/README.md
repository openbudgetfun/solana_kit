# solana_kit_programs

[![pub package](https://img.shields.io/pub/v/solana_kit_programs.svg)](https://pub.dev/packages/solana_kit_programs)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_programs/latest/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Program error identification utilities for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/programs`](https://github.com/anza-xyz/kit/tree/main/packages/programs) from the Solana TypeScript SDK.

## Installation

Add `solana_kit_programs` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_programs:
```

Or, if you are using the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Documentation

- Package page: https://pub.dev/packages/solana_kit_programs
- API reference: https://pub.dev/documentation/solana_kit_programs/latest/

## Usage

### Identifying program errors

The `isProgramError` function determines whether an error is a custom program error from a specific program address. Since the Solana RPC only reports the index of the failed instruction, you must provide the transaction message so the function can look up which program was invoked.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_programs/solana_kit_programs.dart';

void main() {
  const myProgramAddress = Address(
    'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
  );

  // Build a transaction message input with instruction mappings.
  final transactionMessage = TransactionMessageInput(
    instructions: {
      0: InstructionInput(programAddress: myProgramAddress),
      1: InstructionInput(
        programAddress: const Address('11111111111111111111111111111111'),
      ),
    },
  );

  // Simulate an instruction error from the RPC.
  final error = SolanaError(
    SolanaErrorCode.instructionErrorCustom,
    {'index': 0, 'code': 42},
  );

  // Check if this is any custom error from our program.
  print(isProgramError(error, transactionMessage, myProgramAddress));
  // true

  // Check if this is a specific custom error code from our program.
  print(isProgramError(error, transactionMessage, myProgramAddress, 42));
  // true

  // Wrong error code.
  print(isProgramError(error, transactionMessage, myProgramAddress, 99));
  // false

  // Wrong program.
  const otherProgram = Address('11111111111111111111111111111111');
  print(isProgramError(error, transactionMessage, otherProgram));
  // false
}
```

### Catching program errors in transactions

A typical usage pattern is to catch errors after sending a transaction and determine which program raised the error.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_programs/solana_kit_programs.dart';

void main() async {
  const myProgramAddress = Address(
    'MyProgram11111111111111111111111111111111111',
  );

  final transactionMessage = TransactionMessageInput(
    instructions: {
      0: InstructionInput(programAddress: myProgramAddress),
    },
  );

  try {
    // Send and confirm your transaction...
    // await sendAndConfirmTransaction(signedTransaction);
  } catch (error) {
    if (isProgramError(error, transactionMessage, myProgramAddress, 6000)) {
      print('Insufficient funds error from my program');
    } else if (isProgramError(error, transactionMessage, myProgramAddress)) {
      print('Some other custom error from my program');
    } else {
      rethrow;
    }
  }
}
```

### Non-SolanaError values

The function safely returns `false` for non-SolanaError values or errors that are not custom program errors.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_programs/solana_kit_programs.dart';

void main() {
  const programAddress = Address('11111111111111111111111111111111');
  final transactionMessage = TransactionMessageInput(
    instructions: {
      0: InstructionInput(programAddress: programAddress),
    },
  );

  // Not a SolanaError at all.
  print(isProgramError('not an error', transactionMessage, programAddress));
  // false

  // A SolanaError but not a custom instruction error.
  final nonInstructionError = SolanaError(SolanaErrorCode.blockHeightExceeded);
  print(isProgramError(
    nonInstructionError,
    transactionMessage,
    programAddress,
  ));
  // false

  // Null values.
  print(isProgramError(null, transactionMessage, programAddress));
  // false
}
```

## API Reference

### Functions

| Function                                                                                              | Description                                                                                                              |
| ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `isProgramError(Object? error, TransactionMessageInput message, Address programAddress, [int? code])` | Returns `true` if the error is a custom program error from the given program, optionally matching a specific error code. |

### Classes

| Class                     | Description                                                                                                                        |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `TransactionMessageInput` | A minimal transaction message representation with a `Map<int, InstructionInput> instructions` map indexed by instruction position. |
| `InstructionInput`        | A minimal instruction representation containing only a `programAddress`.                                                           |
