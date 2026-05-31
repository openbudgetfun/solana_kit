---
"solana_kit_stake": major
---

# Add Stake program package

Add the Stake Program package with generated instruction builders, stake state codecs, account decoding, and instruction-plan helpers.

```dart
import 'package:solana_kit_stake/solana_kit_stake.dart';

final instruction = getStakeInstruction(
  stake: stakeAddress,
  authorized: authorizedAddress,
);
```
