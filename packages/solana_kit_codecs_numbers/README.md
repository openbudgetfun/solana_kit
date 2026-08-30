# solana_kit_codecs_numbers

[![pub package](https://img.shields.io/pub/v/solana_kit_codecs_numbers.svg)](https://pub.dev/packages/solana_kit_codecs_numbers) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_codecs_numbers/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_codecs_numbers) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_codecs_numbers)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_codecs_numbers)

Numeric codecs for encoding and decoding integers and floats in Solana binary layouts. A port of [`@solana/codecs-numbers`](https://github.com/anza-xyz/kit/tree/main/packages/codecs-numbers) from the Solana TypeScript SDK.

<!-- {=packageInstallSection:"solana_kit_codecs_numbers"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_codecs_numbers": ^0.9.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_codecs_numbers"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_codecs_numbers
- API reference: https://pub.dev/documentation/solana_kit_codecs_numbers/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_codecs_numbers
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_codecs_numbers

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

<!-- {=docsNumberCodecSection} -->

## Encode fixed-width numbers

Use the number codecs when your binary format needs explicit integer widths and endianness.

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final codec = getU64Codec();

  final encoded = codec.encode(BigInt.from(1_000_000));
  final decoded = codec.decode(encoded);

  print(decoded);
}
```

Reach for these codecs in instruction layouts, account state structs, and any wire format that needs exact byte-for-byte compatibility.

<!-- {/docsNumberCodecSection} -->

## Integer and float codecs

All integer codecs default to little-endian byte order, matching Solana's on-chain data layout. Multi-byte codecs accept an optional `NumberCodecConfig` to override endianness.

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  // Unsigned: u8, u16, u32 return int; u64, u128 return BigInt
  getU8Codec().encode(42);                                    // [0x2a]
  getU64Codec().encode(BigInt.from(1000000));                 // 8 bytes, little-endian
  getU128Codec().encode(BigInt.parse('340282366920938463463374607431768211455'));

  // Signed: i8, i16, i32 return int; i64, i128 return BigInt
  getI8Codec().encode(-1);                                    // [0xff]
  getI64Codec().encode(BigInt.from(-1000000));

  // Floats: f32 and f64 return double
  final f32 = getF32Codec();
  final floatVal = f32.decode(Uint8List.fromList([0x00, 0x00, 0xc0, 0x3f]));
  print(floatVal); // 1.5

  // Override endianness
  final bigEndianU32 = getU32Codec(NumberCodecConfig(endian: Endian.big));
  bigEndianU32.encode(42); // [0x00, 0x00, 0x00, 0x2a]
}
```

### shortU16 compact encoding

Solana's variable-length compact encoding for unsigned 16-bit values. Each byte stores 7 bits; bit 7 is a continuation flag.

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final shortU16 = getShortU16Codec();
  shortU16.encode(42);     // 1 byte: [0x2a]
  shortU16.encode(128);    // 2 bytes: [0x80, 0x01]
  shortU16.encode(16384);  // 3 bytes: [0x80, 0x80, 0x01]
  shortU16.decode(Uint8List.fromList([0x80, 0x01])); // 128
}
```

## Key APIs

| Function           | Size      | Dart type |
| ------------------ | --------- | --------- |
| `getU8Codec`       | 1 byte    | `int`     |
| `getU16Codec`      | 2 bytes   | `int`     |
| `getU32Codec`      | 4 bytes   | `int`     |
| `getU64Codec`      | 8 bytes   | `BigInt`  |
| `getU128Codec`     | 16 bytes  | `BigInt`  |
| `getI8Codec`       | 1 byte    | `int`     |
| `getI16Codec`      | 2 bytes   | `int`     |
| `getI32Codec`      | 4 bytes   | `int`     |
| `getI64Codec`      | 8 bytes   | `BigInt`  |
| `getI128Codec`     | 16 bytes  | `BigInt`  |
| `getF32Codec`      | 4 bytes   | `double`  |
| `getF64Codec`      | 8 bytes   | `double`  |
| `getShortU16Codec` | 1-3 bytes | `int`     |

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_codecs_numbers"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_codecs_numbers`.

- Import path: `package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
