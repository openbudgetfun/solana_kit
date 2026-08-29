# solana_kit_anchor

[![pub package](https://img.shields.io/pub/v/solana_kit_anchor.svg)](https://pub.dev/packages/solana_kit_anchor) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_anchor/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_anchor) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_anchor)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_anchor)

Anchor program runtime for the Solana Kit Dart SDK: discriminators, Anchor IDL parsing, dynamic account and event codecs, and Anchor error resolution.

## What you get

- **Discriminators** — Anchor sighash helpers (`sha256("namespace:name")[0..8]`) for instructions, accounts, and events
- **IDL parsing** — a typed model of Anchor IDL 0.30 documents with struct, Rust-enum, tuple, option, vec, and array types
- **Dynamic coder** — build codecs from an IDL at runtime: encode and decode instruction arguments and account data, and extract typed events from program logs (`Program data:` lines)
- **Error resolution** — decode Anchor error codes against the standard Anchor table and program-defined IDL errors
- **Pure-Dart SHA-256** — no platform channels or external crypto dependencies

The package does **not** port the Anchor on-chain framework, the CLI, or client code generation. Programs that rely on generics in their IDLs are better served by Codama-generated clients; the dynamic coder rejects generic type instantiations instead of silently mis-encoding them.

<!-- {=packageInstallSection:"solana_kit_anchor"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_anchor": ^
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

:::

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_anchor": ^
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_anchor
- API reference: https://pub.dev/documentation/solana_kit_anchor/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_anchor
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_anchor

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

<!-- {=docsAnchorRuntimeSection} -->

### Parse an Anchor IDL and code accounts dynamically

Use the runtime coder when a program ships an Anchor IDL: encode instruction arguments, decode account data, and pull typed events out of program logs without writing codecs by hand.

```dart
import 'dart:io';

import 'package:solana_kit_anchor/solana_kit_anchor.dart';

void main() {
  final idl = AnchorIdlProgram.parse(
    File('idls/counter.json').readAsStringSync(),
  );
  final coder = AnchorCoder(idl);

  final data = coder.encodeInstructionData('increment', {
    'delta': BigInt.one,
  });
  // 8-byte discriminator + encoded arguments, ready for an Instruction.
  print(data.length);

  // Account data as fetched from RPC, starting with the 8-byte
  // account discriminator.
  final fetchedAccountBytes = <int>[];
  final counter = coder.decodeAccount('Counter', fetchedAccountBytes);
  print(counter.data['count']); // BigInt

  // Program logs from a transaction, e.g. lines like
  // "Program data: dW5rbm93bkRlY29kZXI=".
  final logs = <String>[];
  final events = coder.decodeEventLogs(logs);
  for (final event in events) {
    print('${event.name}: ${event.data}');
  }
}
```

Discriminator helpers and error resolution round out the runtime: `instructionDiscriminator`, `accountDiscriminator`, `eventDiscriminator`, and `anchorProgramError` resolve against the standard Anchor table plus program-defined IDL errors.

<!-- {/docsAnchorRuntimeSection} -->

## Key APIs

- `anchorSighash(namespace, name)`, `instructionDiscriminator`, `accountDiscriminator`, `eventDiscriminator`
- `AnchorIdlProgram.parse`, `AnchorIdlType.parse`
- `AnchorCoder`: `encodeInstructionData`, `decodeInstructionData`, `encodeAccount`, `decodeAccount`, `decodeEventLogs`
- `anchorProgramError(code, idl: …)`, `standardAnchorErrorMessages`
- `sha256` (FIPS 180-4, pure Dart)

## Reference

The runtime mirrors the behavior of Anchor's TypeScript client (`otter-sec/anchor`, Apache-2.0) for discriminator computation, event emission format, and error code layout.
