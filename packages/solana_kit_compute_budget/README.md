# solana_kit_compute_budget

[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_compute_budget)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_compute_budget) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_compute_budget) Compute Budget program client for the [Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides instruction builders, codecs, and parsers for the Compute Budget program, which controls compute unit limits, priority fees, heap size, and loaded accounts data size.

## Installation

<!-- {=packageInstallSection:"solana_kit_compute_budget"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_compute_budget": ^0.8.2
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

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

## Usage

```dart
import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart';

void main() {
  // Set compute unit limit for a transaction.
  final limitIx = getSetComputeUnitLimitInstruction(
    programAddress: computeBudgetProgramAddress,
    units: 200000,
  );

  // Set priority fee (micro-lamports per compute unit).
  final priceIx = getSetComputeUnitPriceInstruction(
    programAddress: computeBudgetProgramAddress,
    microLamports: BigInt.from(50000),
  );

  // Request a larger heap frame (must be a multiple of 1024).
  final heapIx = getRequestHeapFrameInstruction(
    programAddress: computeBudgetProgramAddress,
    bytes: 256 * 1024,
  );

  // Limit loaded accounts data size.
  final dataLimitIx = getSetLoadedAccountsDataSizeLimitInstruction(
    programAddress: computeBudgetProgramAddress,
    accountDataSizeLimit: 64 * 1024,
  );

  print(limitIx.programAddress);
  print(priceIx.programAddress);
  print(heapIx.programAddress);
  print(dataLimitIx.programAddress);
}
```

## Instructions

| Instruction                      | Discriminator | Description                                                                |
| -------------------------------- | ------------- | -------------------------------------------------------------------------- |
| `RequestUnits`                   | 0             | **Deprecated.** Use `SetComputeUnitLimit` + `SetComputeUnitPrice` instead. |
| `RequestHeapFrame`               | 1             | Request a specific heap frame size in bytes.                               |
| `SetComputeUnitLimit`            | 2             | Set the transaction-wide compute unit limit.                               |
| `SetComputeUnitPrice`            | 3             | Set the compute unit price for priority fees.                              |
| `SetLoadedAccountsDataSizeLimit` | 4             | Set a limit on loaded accounts data size.                                  |

## Inspecting priority fees

`findSetComputeUnitPriceInstructionIndexAndMicroLamports` returns the full unsigned 64-bit price as a `BigInt`, including prices above `2^63 - 1`. Compare this value with your application's fee cap before signing externally supplied transactions. The update helper passes the same unsigned value to its updater callback.

## Upstream reference

Generated layer mirrors [solana-program/compute-budget](https://github.com/solana-program/compute-budget) at `js@v0.18.0`.
