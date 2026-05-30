# solana_kit_memo

[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_memo)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_memo)
Memo program client for the
[Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides generated codecs and ergonomic helpers for the Memo program, which
attaches arbitrary UTF-8 memo text to Solana transactions.

## Installation

```yaml
dependencies:
  solana_kit_memo: ^0.4.0
```

## Usage

```dart
import 'package:solana_kit_memo/solana_kit_memo.dart';

final instruction = getAddMemoInstruction(memo: 'Hello from Solana Kit');
```

Use `memoLegacyProgramAddress` when you need to target the legacy Memo program:

```dart
final legacyInstruction = getAddMemoInstruction(
  memo: 'legacy memo',
  programAddress: memoLegacyProgramAddress,
);
```

## Key APIs

- `getAddMemoInstruction({required String memo})` — builds a Memo instruction from plain
  Dart text.
- `AddMemoInstructionData` — generated instruction data model.
- `getAddMemoInstructionDataCodec()` — UTF-8 codec for AddMemo data.
- `memoProgramAddress` — current Memo program address.
- `memoLegacyProgramAddress` — legacy Memo program address.

## Upstream reference

Generated layer mirrors
[solana-program/memo](https://github.com/solana-program/memo)
at `js@v0.11.0`.
