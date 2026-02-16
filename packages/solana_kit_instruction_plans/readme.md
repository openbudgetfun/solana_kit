# solana_kit_instruction_plans

Plan, organize, and execute complex multi-instruction and multi-transaction operations on Solana.

This is the Dart port of [`@solana/instruction-plans`](https://github.com/anza-xyz/kit/tree/main/packages/instruction-plans) from the Solana TypeScript SDK.

## Installation

```yaml
dependencies:
  solana_kit_instruction_plans:
```

Since this package is part of the `solana_kit` workspace, you can also use the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Overview

Instruction plans describe operations that may go beyond a single instruction and can span multiple transactions. They define a tree of instructions with constraints on execution order:

- **Sequential** -- Instructions that must run in order.
- **Parallel** -- Instructions that can run concurrently.
- **Single** -- A leaf node wrapping one instruction.
- **MessagePacker** -- A dynamic node that packs instructions into transaction messages to fill available space.

The workflow has three stages:

1. **Instruction Plan** -- Describe what needs to happen.
2. **Transaction Planner** -- Convert instruction plans into transaction plans (decides how instructions are grouped into transactions).
3. **Transaction Plan Executor** -- Compile, sign, send, and report results.

## Usage

### Creating instruction plans

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';

final systemProgram = Address('11111111111111111111111111111111');
final alice = Address('mpngsFd4tmbUfzDYJayjKZwZcaR7aWb2793J6grLsGu');
final bob = Address('GDhQoTpNbYUaCAjFKBMCPCdrCaKaLiSqhx5M7r4SrEFy');

final depositFromAlice = singleInstructionPlan(Instruction(
  programAddress: systemProgram,
  accounts: [
    AccountMeta(address: alice, role: AccountRole.writableSigner),
  ],
  data: Uint8List.fromList([2, 0, 0, 0, 0, 202, 154, 59, 0, 0, 0, 0]),
));

final depositFromBob = singleInstructionPlan(Instruction(
  programAddress: systemProgram,
  accounts: [
    AccountMeta(address: bob, role: AccountRole.writableSigner),
  ],
  data: Uint8List.fromList([2, 0, 0, 0, 0, 202, 154, 59, 0, 0, 0, 0]),
));

final activateVault = singleInstructionPlan(Instruction(
  programAddress: systemProgram,
));

final withdrawToAlice = singleInstructionPlan(Instruction(
  programAddress: systemProgram,
  accounts: [
    AccountMeta(address: alice, role: AccountRole.writable),
  ],
));

final withdrawToBob = singleInstructionPlan(Instruction(
  programAddress: systemProgram,
  accounts: [
    AccountMeta(address: bob, role: AccountRole.writable),
  ],
));
```

### Composing plans

Combine instruction plans using sequential and parallel composition:

```dart
// Both deposits can happen in parallel, then activate, then both
// withdrawals can happen in parallel.
final plan = sequentialInstructionPlan([
  parallelInstructionPlan([depositFromAlice, depositFromBob]),
  activateVault,
  parallelInstructionPlan([withdrawToAlice, withdrawToBob]),
]);
```

You can pass `Instruction` objects directly to the factory functions -- they are automatically wrapped in `SingleInstructionPlan`:

```dart
final simplePlan = sequentialInstructionPlan([
  Instruction(programAddress: systemProgram),
  Instruction(programAddress: systemProgram),
]);
```

### Non-divisible plans

When instructions must execute atomically (in a single transaction or bundle), use a non-divisible sequential plan:

```dart
final atomicPlan = nonDivisibleSequentialInstructionPlan([
  Instruction(programAddress: systemProgram),
  Instruction(programAddress: systemProgram),
]);

print(atomicPlan.divisible); // false
```

### Message packer plans

For operations that need to write large amounts of data across multiple transactions, use message packer plans. They dynamically fill each transaction to capacity:

```dart
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';

// Pack data linearly, writing `totalLength` bytes across multiple
// transactions.
final linearPlan = getLinearMessagePackerInstructionPlan(
  getInstruction: (offset, length) => Instruction(
    programAddress: Address('11111111111111111111111111111111'),
    // Build your instruction using the offset and length.
  ),
  totalLength: 50000, // 50 KB of data to write.
);

// Pack a pre-built list of instructions, filling each transaction.
final listPlan = getMessagePackerInstructionPlanFromInstructions([
  Instruction(programAddress: Address('11111111111111111111111111111111')),
  Instruction(programAddress: Address('11111111111111111111111111111111')),
  Instruction(programAddress: Address('11111111111111111111111111111111')),
]);

// Pack realloc instructions in chunks of 10,240 bytes.
final reallocPlan = getReallocMessagePackerInstructionPlan(
  getInstruction: (size) => Instruction(
    programAddress: Address('11111111111111111111111111111111'),
    // Build a realloc instruction for `size` bytes.
  ),
  totalSize: 40960, // 40 KB to reallocate.
);
```

### Planning transactions

A `TransactionPlanner` converts an instruction plan into a `TransactionPlan` -- a tree of transaction messages ready to be compiled and sent:

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

final planner = createTransactionPlanner(
  TransactionPlannerConfig(
    createTransactionMessage: () async {
      // Create a new transaction message with fee payer and lifetime.
      return TransactionMessage(
        version: TransactionVersion.v0,
        feePayer: Address('mpngsFd4tmbUfzDYJayjKZwZcaR7aWb2793J6grLsGu'),
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: 'EkSnNWid2cvwEVnVx9aBqawnmiCNiDgp3gUdkDPTKN1N',
          lastValidBlockHeight: BigInt.from(300000),
        ),
      );
    },
  ),
);

// Convert the instruction plan to a transaction plan.
final transactionPlan = await planner(plan);
```

### Transaction plans

Transaction plans mirror the instruction plan tree structure, but contain `TransactionMessage` objects instead of instructions:

```dart
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

// Create transaction plans directly.
final msg = TransactionMessage(version: TransactionVersion.v0);
final singlePlan = singleTransactionPlan(msg);
final seqPlan = sequentialTransactionPlan([singlePlan, singlePlan]);
final parPlan = parallelTransactionPlan([singlePlan, singlePlan]);
final nonDivPlan = nonDivisibleSequentialTransactionPlan([
  singlePlan,
  singlePlan,
]);
```

### Traversing transaction plan trees

```dart
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';

void main() {
  // Flatten a plan tree into a list of SingleTransactionPlans.
  final allSinglePlans = flattenTransactionPlan(transactionPlan);
  print('Total transactions: ${allSinglePlans.length}');

  // Find the first plan matching a predicate.
  final found = findTransactionPlan(
    transactionPlan,
    (p) => p is SingleTransactionPlan,
  );

  // Check if all plans match a predicate.
  final allSingle = everyTransactionPlan(
    transactionPlan,
    (p) => p is SingleTransactionPlan,
  );

  // Transform plans (bottom-up).
  final transformed = transformTransactionPlan(
    transactionPlan,
    (p) => p, // identity transform
  );
}
```

### Executing transaction plans

A `TransactionPlanExecutor` traverses the transaction plan tree, compiling, signing, and sending each transaction:

```dart
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

final executor = createTransactionPlanExecutor(
  TransactionPlanExecutorConfig(
    executeTransactionMessage: (context, message) async {
      // Compile, sign, and send the transaction message.
      // Return a Signature string or a Transaction object.
      // The `context` map can be used to store intermediate data.
      return 'signature-base58-string';
    },
  ),
);

// Execute the transaction plan.
final result = await executor(transactionPlan);
```

### Inspecting execution results

The execution returns a `TransactionPlanResult` tree that mirrors the plan structure:

```dart
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';

void inspectResults(TransactionPlanResult result) {
  // Summarize results into successful, failed, and canceled lists.
  final summary = summarizeTransactionPlanResult(result);
  print(summary.successful);              // true if all succeeded
  print(summary.successfulTransactions);   // List of successful results
  print(summary.failedTransactions);       // List of failed results
  print(summary.canceledTransactions);     // List of canceled results

  // Check if all results are successful.
  print(isSuccessfulTransactionPlanResult(result));

  // Flatten results into a list.
  final allResults = flattenTransactionPlanResult(result);
  print('Total results: ${allResults.length}');
}
```

### Appending instruction plans to transaction messages

You can directly append all instructions from an instruction plan to a transaction message:

```dart
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

void main() {
  final message = TransactionMessage(version: TransactionVersion.v0);

  final updatedMessage = appendTransactionMessageInstructionPlan(
    plan,
    message,
  );
  print(updatedMessage.instructions.length);
}
```

### Parsing flexible inputs

The package provides helpers that accept `Instruction`, `InstructionPlan`, `TransactionMessage`, or `TransactionPlan` objects and automatically wrap them:

```dart
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

final instruction = Instruction(
  programAddress: Address('11111111111111111111111111111111'),
);

// Automatically wraps in SingleInstructionPlan.
final parsed = parseInstructionPlanInput(instruction);
print(parsed is SingleInstructionPlan); // true

// A list is wrapped in a SequentialInstructionPlan.
final parsedList = parseInstructionPlanInput([instruction, instruction]);
print(parsedList is SequentialInstructionPlan); // true
```

## API Reference

### Sealed classes

- **`InstructionPlan`** -- The base sealed class for instruction plans.
  - **`SingleInstructionPlan`** -- Wraps a single `Instruction`.
  - **`SequentialInstructionPlan`** -- Contains ordered `plans` with a `divisible` flag.
  - **`ParallelInstructionPlan`** -- Contains `plans` that can execute concurrently.
  - **`MessagePackerInstructionPlan`** -- Provides a `getMessagePacker` factory for dynamic packing.

- **`TransactionPlan`** -- The base sealed class for transaction plans.
  - **`SingleTransactionPlan`** -- Wraps a single `TransactionMessage`.
  - **`SequentialTransactionPlan`** -- Contains ordered `plans` with a `divisible` flag.
  - **`ParallelTransactionPlan`** -- Contains `plans` that can execute concurrently.

- **`TransactionPlanResult`** -- The base sealed class for execution results.
  - **`SingleTransactionPlanResult`** -- Base for single transaction results.
    - **`SuccessfulSingleTransactionPlanResult`** -- Contains `signature`.
    - **`FailedSingleTransactionPlanResult`** -- Contains `error`.
    - **`CanceledSingleTransactionPlanResult`** -- Canceled due to earlier failure.
  - **`SequentialTransactionPlanResult`** -- Contains `plans` results list.
  - **`ParallelTransactionPlanResult`** -- Contains `plans` results list.

### Classes

- **`MessagePacker`** -- Returned by `MessagePackerInstructionPlan.getMessagePacker()`, with `done()` and `packMessageToCapacity(message)`.
- **`TransactionPlannerConfig`** -- Configuration with `createTransactionMessage` and optional `onTransactionMessageUpdated`.
- **`TransactionPlanExecutorConfig`** -- Configuration with `executeTransactionMessage`.
- **`TransactionPlanResultSummary`** -- Summary with `successful`, `successfulTransactions`, `failedTransactions`, `canceledTransactions`.

### Type aliases

- **`TransactionPlanner`** -- `Future<TransactionPlan> Function(InstructionPlan)`.
- **`TransactionPlanExecutor`** -- `Future<TransactionPlanResult> Function(TransactionPlan)`.
- **`CreateTransactionMessage`** -- `Future<TransactionMessage> Function()`.
- **`ExecuteTransactionMessage`** -- `Future<Object> Function(Map<String, Object?>, TransactionMessage)`.

### Factory functions

| Function                                | Description                                                |
| --------------------------------------- | ---------------------------------------------------------- |
| `singleInstructionPlan`                 | Wraps an `Instruction` in a `SingleInstructionPlan`.       |
| `sequentialInstructionPlan`             | Creates a divisible sequential plan from a list.           |
| `nonDivisibleSequentialInstructionPlan` | Creates a non-divisible sequential plan.                   |
| `parallelInstructionPlan`               | Creates a parallel plan from a list.                       |
| `singleTransactionPlan`                 | Wraps a `TransactionMessage` in a `SingleTransactionPlan`. |
| `sequentialTransactionPlan`             | Creates a divisible sequential transaction plan.           |
| `nonDivisibleSequentialTransactionPlan` | Creates a non-divisible sequential transaction plan.       |
| `parallelTransactionPlan`               | Creates a parallel transaction plan.                       |

### Tree helpers

| Function                         | Description                                                         |
| -------------------------------- | ------------------------------------------------------------------- |
| `flattenInstructionPlan`         | Flattens an instruction plan tree into leaf plans.                  |
| `findInstructionPlan`            | Depth-first search for the first matching plan.                     |
| `everyInstructionPlan`           | Returns `true` if all plans satisfy a predicate.                    |
| `transformInstructionPlan`       | Bottom-up transformation of the plan tree.                          |
| `flattenTransactionPlan`         | Flattens a transaction plan tree into `SingleTransactionPlan` list. |
| `findTransactionPlan`            | Depth-first search for the first matching transaction plan.         |
| `everyTransactionPlan`           | Returns `true` if all transaction plans satisfy a predicate.        |
| `transformTransactionPlan`       | Bottom-up transformation of the transaction plan tree.              |
| `flattenTransactionPlanResult`   | Flattens results into `SingleTransactionPlanResult` list.           |
| `findTransactionPlanResult`      | Depth-first search for the first matching result.                   |
| `everyTransactionPlanResult`     | Returns `true` if all results satisfy a predicate.                  |
| `transformTransactionPlanResult` | Bottom-up transformation of the result tree.                        |

### Message packer factories

| Function                                          | Description                                                 |
| ------------------------------------------------- | ----------------------------------------------------------- |
| `getLinearMessagePackerInstructionPlan`           | Packs data linearly with offset/length across transactions. |
| `getMessagePackerInstructionPlanFromInstructions` | Packs a list of instructions, filling each transaction.     |
| `getReallocMessagePackerInstructionPlan`          | Packs realloc instructions in 10,240-byte chunks.           |

### Planner and executor

| Function                                    | Description                                                         |
| ------------------------------------------- | ------------------------------------------------------------------- |
| `createTransactionPlanner`                  | Creates a `TransactionPlanner` from config.                         |
| `createTransactionPlanExecutor`             | Creates a `TransactionPlanExecutor` from config.                    |
| `passthroughFailedTransactionPlanExecution` | Catches executor errors and returns the result instead of throwing. |
| `summarizeTransactionPlanResult`            | Categorizes results into successful, failed, and canceled.          |
| `getFirstFailedSingleTransactionPlanResult` | Finds the first failed result in a tree.                            |

### Other functions

| Function                                  | Description                                                    |
| ----------------------------------------- | -------------------------------------------------------------- |
| `appendTransactionMessageInstructionPlan` | Appends all instructions from a plan to a transaction message. |
| `parseInstructionPlanInput`               | Parses flexible input into an `InstructionPlan`.               |
| `parseTransactionPlanInput`               | Parses flexible input into a `TransactionPlan`.                |
