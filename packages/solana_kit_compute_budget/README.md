# solana_kit_compute_budget

Compute Budget program client for the
[Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides instruction builders, codecs, and parsers for the Compute Budget
program, which controls compute unit limits, priority fees, heap size, and
loaded accounts data size.

## Installation

```yaml
dependencies:
  solana_kit_compute_budget: ^0.3.1
```

## Usage

```dart
import 'package:solana_kit_compute_budget/solana_kit_compute_budget.dart';

// Set compute unit limit for a transaction
final limitIx = getSetComputeUnitLimitInstruction(units: 200000);

// Set priority fee (micro-lamports per compute unit)
final priceIx = getSetComputeUnitPriceInstruction(
  microLamports: BigInt.from(50000),
);

// Request a larger heap frame (must be a multiple of 1024)
final heapIx = getRequestHeapFrameInstruction(bytes: 256 * 1024);

// Limit loaded accounts data size
final dataLimitIx = getSetLoadedAccountsDataSizeLimitInstruction(
  accountDataSizeLimit: 64 * 1024,
);
```

## Instructions

| Instruction                      | Discriminator | Description                                                                |
| -------------------------------- | ------------- | -------------------------------------------------------------------------- |
| `RequestUnits`                   | 0             | **Deprecated.** Use `SetComputeUnitLimit` + `SetComputeUnitPrice` instead. |
| `RequestHeapFrame`               | 1             | Request a specific heap frame size in bytes.                               |
| `SetComputeUnitLimit`            | 2             | Set the transaction-wide compute unit limit.                               |
| `SetComputeUnitPrice`            | 3             | Set the compute unit price for priority fees.                              |
| `SetLoadedAccountsDataSizeLimit` | 4             | Set a limit on loaded accounts data size.                                  |

## Upstream reference

Generated layer mirrors
[solana-program/compute-budget](https://github.com/solana-program/compute-budget)
at `js@v0.15.0`.
