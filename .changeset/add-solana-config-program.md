---
"solana_kit_config": major
---

# Add Solana Config program client

Add the Solana Config program package with generated codecs, account decoder, Store instruction builder, and typed store helper.

```dart
import 'package:solana_kit_config/solana_kit_config.dart';

final instruction = getStoreConfigInstruction(
  configAccount: configAddress,
  keys: ConfigKeys(keys: [ConfigKey(pubkey: signer, isSigner: true)]),
  configData: Uint8List.fromList([1, 2, 3]),
);
```
