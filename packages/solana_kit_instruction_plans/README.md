# solana_kit_instruction_plans

[![pub package](https://img.shields.io/pub/v/solana_kit_instruction_plans.svg)](https://pub.dev/packages/solana_kit_instruction_plans) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_instruction_plans/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_instruction_plans) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_instruction_plans)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_instruction_plans)

Plan, organize, and execute complex multi-instruction and multi-transaction operations on Solana.

Use this package when a workflow needs several instructions that must run in a specific order, in parallel, or across multiple transactions. Plans describe the shape of the work; executors turn them into signed, sent transactions.

<!-- {=packageInstallSection:"solana_kit_instruction_plans"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_instruction_plans": ^0.9.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_instruction_plans"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_instruction_plans
- API reference: https://pub.dev/documentation/solana_kit_instruction_plans/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_instruction_plans
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_instruction_plans

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Composing plans

`singleInstructionPlan` wraps one instruction. `sequentialInstructionPlan` and `parallelInstructionPlan` combine plans, and `InstructionPlan` is a sealed type you can pattern match on.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

void main() {
  const instructionA = Instruction(
    programAddress: Address('11111111111111111111111111111111'),
  );
  const instructionB = Instruction(
    programAddress: Address('11111111111111111111111111111111'),
  );

  final plan = sequentialInstructionPlan([
    singleInstructionPlan(instructionA),
    parallelInstructionPlan([instructionB]),
  ]);

  print('Instruction plan kind: ${plan.kind}');
  print('Instruction plan steps: ${plan.plans.length}');
}
```

### Packing instructions into messages

`MessagePackerInstructionPlan` carries a `getMessagePacker` callback that builds a `MessagePacker`, which fills transaction messages up to a byte capacity. That is how large instruction sets get split across transactions.

The built-in instruction-list packer preserves every instruction exactly once, leaving the next instruction pending when a message reaches its byte or instruction limit. Custom packers must only advance past instructions included in their returned message and leave their progress unchanged when throwing.

Reserve fixed instructions, such as compute-budget instructions, in `createTransactionMessage`. If `onTransactionMessageUpdated` makes a packed message exceed its limits, planning fails rather than discarding already consumed instructions and returning an incomplete plan.

```dart
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';

void main() {
  final plan = MessagePackerInstructionPlan(
    getMessagePacker: () => MessagePacker(
      done: () => false,
      packMessageToCapacity: (message, {maxInstructions}) => message,
    ),
  );

  print(plan.kind);
}
```

### Inspecting execution failures

Execution errors preserve the complete result tree, including signatures for earlier successful transactions and the original failure. An unsigned transaction in a failed callback's context remains available for inspection without replacing the failure with a signature-extraction error. Use `passthroughFailedTransactionPlanExecution` to retrieve the result tree when handling partial execution.

## Key APIs

- `InstructionPlan` sealed type: `SingleInstructionPlan`, `SequentialInstructionPlan`, `ParallelInstructionPlan`.
- `singleInstructionPlan`, `sequentialInstructionPlan`, `parallelInstructionPlan`.
- `getMessagePacker`, `MessagePacker`.
- `TransactionPlan`, `TransactionPlanner`, `TransactionPlanExecutor`, `TransactionExecutionBoundary`.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_instruction_plans"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_instruction_plans`.

- Import path: `package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
