# solana_kit_loader

[![pub package](https://img.shields.io/pub/v/solana_kit_loader.svg)](https://pub.dev/packages/solana_kit_loader) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_loader) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![codecov](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Dart helpers for Solana's BPF Loader v3 (Upgradeable) and Loader v4 programs.

## Usage

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_loader/solana_kit_loader.dart';

final instruction = getWriteInstruction(
  programAddress: solanaLoaderV3ProgramProgramAddress,
  bufferAccount: const Address('11111111111111111111111111111111'),
  bufferAuthority: const Address('11111111111111111111111111111112'),
  offset: 0,
  bytes: Uint8List.fromList([1, 2, 3]),
);
```

## Key APIs

- Program constants: `solanaLoaderV3ProgramProgramAddress`, `bpfLoaderUpgradeableProgramAddress`, and `loaderV4ProgramAddress`.
- Generated Loader v3 instructions: initialize buffer, write, deploy with max data length, upgrade, set authority, close, extend program, and checked authority update.
- Handwritten Loader v3 account-header codecs: `BufferAccount` and `ProgramDataAccount`.
- Loader v4 instructions: write, truncate, deploy, retract, transfer authority, and finalize.
- Handwritten Loader v4 account-header codec: `ProgramStateAccount`.
- Planning helpers: `getDeployProgramInstructionPlan` and `getUpgradeProgramInstructionPlan` chunk program bytes into loader writes before the deploy or upgrade instruction.
