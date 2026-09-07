# Solana Kit Config

[![pub package](https://img.shields.io/pub/v/solana_kit_config.svg)](https://pub.dev/packages/solana_kit_config) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_config) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![codecov](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Config program client for the Solana Kit Dart SDK.

This package provides generated codecs, account decoders, and instruction builders for Solana's native Config program, plus ergonomic helpers for storing configuration data.

## Usage

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_config/solana_kit_config.dart';

void main() {
  final configAccount = address('11111111111111111111111111111111');
  final authority = address('Config1111111111111111111111111111111111111');

  final instruction = getStoreConfigInstruction(
    configAccount: configAccount,
    keys: [ConfigKey(address: authority, isSigner: true)],
    configData: Uint8List.fromList([1, 2, 3]),
    configAccountIsSigner: true,
  );

  final parsed = parseStoreInstruction(instruction);
  assert(parsed.data.length == 3);
}
```

<!-- {=generatedProgramClientSection} -->

## How generated program clients work

Generated program clients share one API shape, so what you learn in one program transfers to the next:

- **Program address constant** — a `...ProgramAddress` constant identifies the program on-chain.
- **Identification helpers** — `identify...Program` and `identify...Instruction` match programs and instructions without string comparisons.
- **Instruction builders and parsers** — `get...Instruction` encodes parameters, `parse...Instruction` decodes a transaction instruction back into typed arguments.
- **Account codecs** — `get...AccountCodec` and `decode...Account` turn on-chain bytes into typed account objects.
- **Plan helpers** — `get...InstructionPlan` helpers compose multi-instruction flows (such as creating an account before acting on it) into transaction plans the standard executor can run.

Errors thrown by these helpers and by transaction execution surface as `SolanaError`; match program-specific failures with the program error helpers.

<!-- {/generatedProgramClientSection} -->

<!-- {=programErrorHandlingSection} -->

## Match program errors from your program

Transaction failures surface as `SolanaError` values. When a transaction fails with a custom program error, the RPC response identifies the failing instruction by index — pair it with the transaction message to attribute the error to a program and match custom error codes.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_programs/solana_kit_programs.dart';

Future<void> handleTransactionFailure(Object error) async {
  const myProgramAddress = Address('11111111111111111111111111111111');
  final transactionMessage = TransactionMessageInput(
    instructions: {0: InstructionInput(programAddress: myProgramAddress)},
  );

  if (isProgramError(error, transactionMessage, myProgramAddress, 42)) {
    // Custom program error code 42 from this program.
  } else if (isProgramError(error, transactionMessage, myProgramAddress)) {
    // Any other custom error from this program.
  }
}
```

`transactionMessage` is a lightweight `TransactionMessageInput` — a map from instruction index to `InstructionInput(programAddress: ...)`. Build it from the same instructions you sent, so matching stays accurate even when the transaction mixes instructions from several programs.

<!-- {/programErrorHandlingSection} -->

## Key APIs

- `solanaConfigProgramAddress` — the native Config program address.
- `identifySolanaConfigProgram` / `identifySolanaConfigInstruction` — helpers for program and instruction identification.
- `ConfigKey`, `ConfigKeys`, and related codecs — encode the Config key list using Solana's short-vector format.
- `ConfigAccount`, `getConfigAccountCodec`, and `decodeConfigAccount` — decode Config account data into typed Dart objects.
- `getStoreInstruction` / `parseStoreInstruction` — generated `Store` instruction builder and parser.
- `getStoreConfigInstruction` — helper wrapper that accepts config data and derives signer accounts from typed config keys.

## License

MIT
