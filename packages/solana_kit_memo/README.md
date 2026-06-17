# solana_kit_memo

[![Coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_memo)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_memo)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_memo)
Memo program client for the
[Solana Kit](https://github.com/openbudgetfun/solana_kit) Dart SDK.

Provides generated codecs and ergonomic helpers for the Memo program, which
attaches arbitrary UTF-8 memo text to Solana transactions.

## Installation

<!-- {=packageInstallSection:"solana_kit_memo"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_memo": ^0.1.1
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

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
