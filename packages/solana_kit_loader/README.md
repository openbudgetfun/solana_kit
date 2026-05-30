# solana_kit_loader

[![pub package](https://img.shields.io/pub/v/solana_kit_loader.svg)](https://pub.dev/packages/solana_kit_loader)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Dart helpers for Solana's BPF Loader v3 (Upgradeable) and Loader v4 programs.

## Usage

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_loader/solana_kit_loader.dart';

final instruction = getLoaderV3WriteInstruction(
  bufferAccount: const Address('11111111111111111111111111111111'),
  bufferAuthority: const Address('11111111111111111111111111111112'),
  offset: 0,
  bytes: Uint8List.fromList([1, 2, 3]),
);
```

## Key APIs

- Program constants: `bpfLoaderUpgradeableProgramAddress`, `loaderV4ProgramAddress`.
- Loader v3 instructions: initialize buffer, write, deploy with max data length,
  upgrade, set authority, close, extend program, and checked authority update.
- Loader v3 account codecs: `BufferAccount`, `ProgramDataAccount`.
- Loader v4 instructions: write, truncate, deploy, retract, transfer authority,
  and finalize.
- Loader v4 account codec: `ProgramStateAccount`.
- Planning helpers: `getDeployProgramInstructionPlan` and
  `getUpgradeProgramInstructionPlan` chunk program bytes into loader writes before
  the deploy or upgrade instruction.
