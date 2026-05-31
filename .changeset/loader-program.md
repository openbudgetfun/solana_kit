---
"solana_kit_loader": major
---

# Add Loader program package

Add a new loader package with BPF Loader v3 (Upgradeable) and Loader v4 program addresses, instruction builders, account header codecs, and deployment/upgrade instruction plan helpers.

```dart
import 'package:solana_kit_loader/solana_kit_loader.dart';

final instruction = getUpgradeInstruction(
  programDataAddress: programDataAddress,
  programAddress: programAddress,
  authority: authorityAddress,
  buffer: bufferAddress,
);
```
