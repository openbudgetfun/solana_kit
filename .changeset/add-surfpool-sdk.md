---
"solana_kit_surfpool": major
---

# Add Surfpool SDK package

Adds a new pure-Dart, CLI-backed Surfpool SDK package for starting local Surfnets and using Surfpool cheatcodes from Dart tests. The package intentionally avoids native napi or Flutter Rust Bridge bindings while exposing typed helpers for funding accounts, mutating token state, time travel, and program deployment.

```dart
final surfnet = await Surfnet.start();
try {
  final payer = surfnet.payer;
  await surfnet.fundSol(payer, 1_000_000_000);
} finally {
  await surfnet.stop();
}
```
