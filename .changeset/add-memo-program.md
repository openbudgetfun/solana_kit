---
"solana_kit_memo": major
---

# Add Memo program package

Added `solana_kit_memo` with generated AddMemo codecs, current and legacy program addresses, ergonomic memo instruction helper, documentation, and tests.

```dart
import 'package:solana_kit_memo/solana_kit_memo.dart';

final instruction = getAddMemoInstruction(memo: 'Hello Solana!');
```
