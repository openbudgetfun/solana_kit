# solana_kit_codecs_core

[![pub package](https://img.shields.io/pub/v/solana_kit_codecs_core.svg)](https://pub.dev/packages/solana_kit_codecs_core) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_codecs_core/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_codecs_core) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_codecs_core)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_codecs_core)

The `Encoder`, `Decoder`, and `Codec` interfaces at the base of every Solana Kit codec, plus the helpers that adapt, wrap, and combine them.

Use this package when you are building a custom codec or need to transform an existing one. Most applications reach codecs through `solana_kit_codecs` or the `solana_kit` umbrella.

<!-- {=packageInstallSection:"solana_kit_codecs_core"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_codecs_core": ^0.9.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_codecs_core"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_codecs_core
- API reference: https://pub.dev/documentation/solana_kit_codecs_core/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_codecs_core
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_codecs_core

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

<!-- {=docsCoreCodecSection} -->

## Compose core codecs

Use `solana_kit_codecs_core` when you need to adapt, wrap, or combine lower- level encoders and decoders.

```dart
import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final codec = addCodecSentinel(getU8Codec(), Uint8List.fromList([255]));

  final encoded = codec.encode(42);
  final decoded = codec.decode(encoded);

  print(encoded);
  print(decoded);
}
```

These helpers are the glue layer between simple primitive codecs and the more specialized Solana-facing structures built on top of them.

<!-- {/docsCoreCodecSection} -->

## Usage

### Fixed-size and variable-size codecs

A codec is either fixed-size (always consumes the same number of bytes) or variable-size. The concrete classes `FixedSizeCodec`, `VariableSizeCodec`, and their encoder/decoder counterparts expose `fixedSize` and `maxSize` so callers can plan buffer layouts.

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

void main() {
  final u32Codec = getU32Codec();
  print(u32Codec.fixedSize); // 4

  final utf8Codec = getUtf8Codec();
  print(utf8Codec.maxSize); // null (unbounded)
}
```

### Combining encoders and decoders

`combineCodec` pairs an encoder and a decoder into a single `Codec`. `fixCodecSize` and `addCodecSizePrefix` adjust how a codec's length is represented on the wire.

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final codec = combineCodec(getU16Encoder(), getU16Decoder());
  final bytes = codec.encode(258);
  print(bytes); // [2, 1] little-endian
  print(codec.decode(bytes)); // 258
}
```

### Transforming values

`transformEncoder`, `transformDecoder`, and `transformCodec` map between a codec's wire type and a domain type.

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final codec = transformCodec(
    getU8Codec(),
    (int value) => value + 1,
    (int value, bytes, offset) => value - 1,
  );

  final bytes = codec.encode(41);
  print(codec.decode(bytes)); // 41
}
```

## Key APIs

- `Encoder<T>`, `Decoder<T>`, `Codec<T, TFrom>`: the three core interfaces.
- `FixedSizeEncoder/Decoder/Codec` and `VariableSizeEncoder/Decoder/Codec`: concrete implementations with size metadata.
- `combineCodec`, `fixCodecSize`, `addCodecSizePrefix`, `addCodecSentinel`, `transformEncoder/Decoder/Codec`, `getEncodedSize`, `assertIsFixedSize`, `assertIsVariableSize`.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_codecs_core"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_codecs_core/solana_kit_codecs_core.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_codecs_core`.

- Import path: `package:solana_kit_codecs_core/solana_kit_codecs_core.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
