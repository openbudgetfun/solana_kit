# solana_kit_memo

[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_memo)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_memo) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_memo) Memo program client for the [Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides generated codecs and ergonomic helpers for the Memo program, which attaches arbitrary UTF-8 memo text to Solana transactions.

## Installation

<!-- {=packageInstallSection:"solana_kit_memo"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_memo": ^0.4.2
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

## Usage

```dart
import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_memo/solana_kit_memo.dart';

void main() {
  final instruction = getAddMemoInstruction(
    programAddress: memoProgramAddress,
    memo: 'Hello from Solana Kit',
  );

  print(instruction.programAddress);
}
```

Use `memoLegacyProgramAddress` when you need to target the legacy Memo program:

```dart
import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
import 'package:solana_kit_memo/solana_kit_memo.dart';

void main() {
  final legacyInstruction = getAddMemoInstruction(
    programAddress: memoLegacyProgramAddress,
    memo: 'legacy memo',
  );

  print(legacyInstruction.programAddress);
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

- `getAddMemoInstruction({required String memo})` — builds a Memo instruction from plain Dart text.
- `AddMemoInstructionData` — generated instruction data model.
- `getAddMemoInstructionDataCodec()` — UTF-8 codec for AddMemo data.
- `memoProgramAddress` — current Memo program address.
- `memoLegacyProgramAddress` — legacy Memo program address.

## Upstream reference

Generated layer mirrors [solana-program/memo](https://github.com/solana-program/memo) at `js@v0.13.0`.
