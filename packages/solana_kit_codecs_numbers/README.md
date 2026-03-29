# solana_kit_codecs_numbers

[![pub package](https://img.shields.io/pub/v/solana_kit_codecs_numbers.svg)](https://pub.dev/packages/solana_kit_codecs_numbers)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_codecs_numbers/latest/)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Numeric codecs for encoding and decoding integers and floats in Solana data structures.

This is a Dart port of [`@solana/codecs-numbers`](https://github.com/anza-xyz/kit/tree/main/packages/codecs-numbers) from the Solana TypeScript SDK.

<!-- {=packageInstallSection:"solana_kit_codecs_numbers"} -->

## Installation

Install the package directly:

```bash
dart pub add solana_kit_codecs_numbers
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

Use the number codecs when your binary format needs explicit integer widths and
endianness.

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  final codec = getU64Codec();

  final encoded = codec.encode(BigInt.from(1_000_000));
  final decoded = codec.decode(encoded);

  print(decoded);
}
```

Reach for these codecs in instruction layouts, account state structs, and any
wire format that needs exact byte-for-byte compatibility.

<!-- {/docsNumberCodecSection} -->

## Usage

### Unsigned integers

All integer codecs default to **little-endian** byte order, matching Solana's on-chain data layout.

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

// u8: unsigned 8-bit integer (1 byte)
final u8 = getU8Codec();
u8.encode(42);                              // Uint8List [0x2a]
u8.decode(Uint8List.fromList([0x2a]));      // 42

// u16: unsigned 16-bit integer (2 bytes, little-endian)
final u16 = getU16Codec();
u16.encode(512);                            // Uint8List [0x00, 0x02]
u16.decode(Uint8List.fromList([0x00, 0x02])); // 512

// u32: unsigned 32-bit integer (4 bytes, little-endian)
final u32 = getU32Codec();
u32.encode(42);                             // Uint8List [0x2a, 0x00, 0x00, 0x00]
u32.decode(Uint8List.fromList([0x2a, 0x00, 0x00, 0x00])); // 42
```

### Large unsigned integers (BigInt)

For 64-bit and 128-bit values, `BigInt` is used instead of `int` to avoid precision loss:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

// u64: unsigned 64-bit integer (8 bytes)
final u64 = getU64Codec();
u64.encode(BigInt.from(1000000));
// Uint8List [0x40, 0x42, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00]

final decoded = u64.decode(
  Uint8List.fromList([0x40, 0x42, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00]),
);
// decoded == BigInt.from(1000000)

// u128: unsigned 128-bit integer (16 bytes)
final u128 = getU128Codec();
u128.encode(BigInt.parse('340282366920938463463374607431768211455'));
```

### Signed integers

Signed integers use two's complement representation:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

// i8: signed 8-bit integer (1 byte, range -128 to 127)
final i8 = getI8Codec();
i8.encode(-1);                              // Uint8List [0xff]
i8.decode(Uint8List.fromList([0xff]));      // -1

// i16: signed 16-bit integer (2 bytes)
final i16 = getI16Codec();
i16.encode(-256);                           // little-endian encoding

// i32: signed 32-bit integer (4 bytes)
final i32 = getI32Codec();
i32.encode(-42);

// i64 and i128 use BigInt
final i64 = getI64Codec();
i64.encode(BigInt.from(-1000000));

final i128 = getI128Codec();
i128.encode(BigInt.from(-1));
```

### Floating-point numbers

IEEE 754 floating-point codecs for 32-bit and 64-bit floats:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

// f32: 32-bit float (4 bytes)
final f32 = getF32Codec();
f32.encode(1.5);
final float = f32.decode(Uint8List.fromList([0x00, 0x00, 0xc0, 0x3f]));
// float == 1.5

// f64: 64-bit float (8 bytes)
final f64Codec = getF64Codec();
f64Codec.encode(3.141592653589793);
```

### Solana shortU16 compact encoding

The `shortU16` encoding is Solana's variable-length compact encoding for unsigned 16-bit values. It uses 1 to 3 bytes depending on the magnitude:

- Values 0-127: 1 byte
- Values 128-16383: 2 bytes
- Values 16384-65535: 3 bytes

Each byte stores 7 bits of data; bit 7 is a continuation flag.

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

final shortU16 = getShortU16Codec();

// Small values use 1 byte.
shortU16.encode(42);    // Uint8List [0x2a]

// Medium values use 2 bytes.
shortU16.encode(128);   // Uint8List [0x80, 0x01]

// Large values use 3 bytes.
shortU16.encode(16384); // Uint8List [0x80, 0x80, 0x01]

// Decoding
shortU16.decode(Uint8List.fromList([0x80, 0x01])); // 128
```

### Using individual encoders and decoders

Each codec function has corresponding encoder-only and decoder-only variants. This is useful when you only need one direction, or when composing with other codec utilities:

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

// Encoder only
final encoder = getU32Encoder();
final bytes = encoder.encode(100);

// Decoder only
final decoder = getU32Decoder();
final value = decoder.decode(bytes);

// Read with offset tracking
final (decoded, nextOffset) = decoder.read(bytes, 0);
// decoded == 100, nextOffset == 4
```

### Configuring endianness

Multi-byte number codecs accept an optional `NumberCodecConfig` to override the default little-endian byte order:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

// Big-endian u32
final bigEndianU32 = getU32Codec(NumberCodecConfig(endian: Endian.big));
bigEndianU32.encode(42); // Uint8List [0x00, 0x00, 0x00, 0x2a]

// Little-endian (default)
final littleEndianU32 = getU32Codec();
littleEndianU32.encode(42); // Uint8List [0x2a, 0x00, 0x00, 0x00]
```

## API Reference

### Unsigned integer codecs

| Function                                                   | Size     | Dart Type     | Range              |
| ---------------------------------------------------------- | -------- | ------------- | ------------------ |
| `getU8Encoder()` / `getU8Decoder()` / `getU8Codec()`       | 1 byte   | `num` / `int` | 0 to 255           |
| `getU16Encoder()` / `getU16Decoder()` / `getU16Codec()`    | 2 bytes  | `num` / `int` | 0 to 65,535        |
| `getU32Encoder()` / `getU32Decoder()` / `getU32Codec()`    | 4 bytes  | `num` / `int` | 0 to 4,294,967,295 |
| `getU64Encoder()` / `getU64Decoder()` / `getU64Codec()`    | 8 bytes  | `BigInt`      | 0 to 2^64-1        |
| `getU128Encoder()` / `getU128Decoder()` / `getU128Codec()` | 16 bytes | `BigInt`      | 0 to 2^128-1       |

### Signed integer codecs

| Function                                                   | Size     | Dart Type     | Range             |
| ---------------------------------------------------------- | -------- | ------------- | ----------------- |
| `getI8Encoder()` / `getI8Decoder()` / `getI8Codec()`       | 1 byte   | `num` / `int` | -128 to 127       |
| `getI16Encoder()` / `getI16Decoder()` / `getI16Codec()`    | 2 bytes  | `num` / `int` | -32,768 to 32,767 |
| `getI32Encoder()` / `getI32Decoder()` / `getI32Codec()`    | 4 bytes  | `num` / `int` | -2^31 to 2^31-1   |
| `getI64Encoder()` / `getI64Decoder()` / `getI64Codec()`    | 8 bytes  | `BigInt`      | -2^63 to 2^63-1   |
| `getI128Encoder()` / `getI128Decoder()` / `getI128Codec()` | 16 bytes | `BigInt`      | -2^127 to 2^127-1 |

### Floating-point codecs

| Function                                                | Size    | Dart Type        |
| ------------------------------------------------------- | ------- | ---------------- |
| `getF32Encoder()` / `getF32Decoder()` / `getF32Codec()` | 4 bytes | `num` / `double` |
| `getF64Encoder()` / `getF64Decoder()` / `getF64Codec()` | 8 bytes | `num` / `double` |

### Special codecs

| Function                                                               | Size      | Description                 |
| ---------------------------------------------------------------------- | --------- | --------------------------- |
| `getShortU16Encoder()` / `getShortU16Decoder()` / `getShortU16Codec()` | 1-3 bytes | Solana compact u16 encoding |

### Configuration

| Type                | Description                                                         |
| ------------------- | ------------------------------------------------------------------- |
| `NumberCodecConfig` | Configuration with `endian` parameter (defaults to `Endian.little`) |

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
