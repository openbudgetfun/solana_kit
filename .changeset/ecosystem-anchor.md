---
"solana_kit_anchor": major
---

# Support Anchor programs in Dart

Add the Anchor runtime package: Anchor sighash discriminators (`sha256("namespace:name")[0..8]`), Anchor IDL 0.30 parsing, a dynamic coder that builds account, instruction, and event codecs from an IDL at runtime, a pure-Dart SHA-256, and Anchor error resolution against the standard table plus program-defined IDL errors. Generic IDL type instantiations are rejected at codec-build time.

```dart
import 'package:solana_kit_anchor/solana_kit_anchor.dart';

final idl = AnchorIdlProgram.parse(idlJson);
final coder = AnchorCoder(idl);
final args = coder.encodeInstructionData('initialize', {
  'authority': authorityAddress,
});
```
