# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_surfpool [0.1.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_surfpool/v0.1.0) (2026-06-29)

### 💥 Breaking Change

#### Add Surfpool SDK package

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

_Owner:_ Ifiok Jr. · _Introduced in:_ [`323386f`](https://github.com/openbudgetfun/solana_kit/commit/323386ff010ee0fbd7e07f3a8f007b8bc5a1dabb)

## 0.0.0

- Initial unpublished package version.
