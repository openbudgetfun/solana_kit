# Solana Kit Config

[![pub package](https://img.shields.io/pub/v/solana_kit_config.svg)](https://pub.dev/packages/solana_kit_config)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Config program client for the Solana Kit Dart SDK.

This package provides generated codecs, account decoders, and instruction
builders for Solana's native Config program, plus ergonomic helpers for storing
configuration data.

## Usage

```dart
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_config/solana_kit_config.dart';

void main() {
  final configAccount = address('11111111111111111111111111111111');
  final authority = address('Config1111111111111111111111111111111111111');

  final instruction = getStoreConfigInstruction(
    configAccount: configAccount,
    keys: [ConfigKey(address: authority, isSigner: true)],
    configData: Uint8List.fromList([1, 2, 3]),
    configAccountIsSigner: true,
  );

  final parsed = parseStoreInstruction(instruction);
  assert(parsed.data.length == 3);
}
```

## Key APIs

- `solanaConfigProgramAddress` — the native Config program address.
- `identifySolanaConfigProgram` / `identifySolanaConfigInstruction` — helpers
  for program and instruction identification.
- `ConfigKey`, `ConfigKeys`, and related codecs — encode the Config key list
  using Solana's short-vector format.
- `ConfigAccount`, `getConfigAccountCodec`, and `decodeConfigAccount` — decode
  Config account data into typed Dart objects.
- `getStoreInstruction` / `parseStoreInstruction` — generated `Store`
  instruction builder and parser.
- `getStoreConfigInstruction` — helper wrapper that accepts config data and
  derives signer accounts from typed config keys.

## License

MIT
