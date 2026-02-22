# solana_kit_codecs_strings

[![pub package](https://img.shields.io/pub/v/solana_kit_codecs_strings.svg)](https://pub.dev/packages/solana_kit_codecs_strings)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_codecs_strings/latest/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

String codecs for encoding and decoding string data in various bases (base-10, base-16, base-58, base-64, UTF-8) for Solana data structures.

This is a Dart port of [`@solana/codecs-strings`](https://github.com/anza-xyz/kit/tree/main/packages/codecs-strings) from the Solana TypeScript SDK.

## Installation

```yaml
dependencies:
  solana_kit_codecs_strings:
```

Since this package is part of the `solana_kit` Dart workspace, it is resolved automatically. For standalone use, point to the repository or use a path dependency.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_codecs_strings
- API reference: https://pub.dev/documentation/solana_kit_codecs_strings/latest/

## Usage

### Base-58 encoding

Base-58 is the primary encoding used for Solana addresses, public keys, and signatures. It uses the Bitcoin alphabet (`123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz`), which omits visually ambiguous characters (0, O, I, l).

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

// Encode a base-58 string to bytes.
final encoder = getBase58Encoder();
final bytes = encoder.encode('4wBqpZM9xaSheZzJSMawUHDgZ7miWfSsxmfVF5jJpYP');

// Decode bytes back to a base-58 string.
final decoder = getBase58Decoder();
final address = decoder.decode(bytes);
// address == '4wBqpZM9xaSheZzJSMawUHDgZ7miWfSsxmfVF5jJpYP'

// Or use the combined codec.
final codec = getBase58Codec();
final roundTripped = codec.decode(codec.encode('hello'));
// roundTripped == 'hello'
```

### Base-16 (hexadecimal) encoding

Encode and decode hexadecimal strings:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

final codec = getBase16Codec();

// Encode hex string to bytes.
final bytes = codec.encode('deadbeef');
// bytes == Uint8List [0xde, 0xad, 0xbe, 0xef]

// Decode bytes to hex string.
final hex = codec.decode(Uint8List.fromList([0xde, 0xad, 0xbe, 0xef]));
// hex == 'deadbeef'
```

### Base-64 encoding

Encode and decode base-64 strings, commonly used in Solana RPC responses:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

final codec = getBase64Codec();

// Encode a base-64 string to bytes.
final bytes = codec.encode('SGVsbG8gV29ybGQ=');
// bytes contains the decoded binary data

// Decode bytes to a base-64 string.
final encoded = codec.decode(Uint8List.fromList([72, 101, 108, 108, 111]));
// encoded == 'SGVsbG8='
```

### Base-10 encoding

Encode and decode base-10 (decimal) strings:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

final codec = getBase10Codec();

final bytes = codec.encode('12345');
final decoded = codec.decode(bytes);
// decoded == '12345'
```

### UTF-8 encoding

Encode and decode UTF-8 strings. This is a variable-size codec since the byte length depends on the string content:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

final codec = getUtf8Codec();

// Encode a string to UTF-8 bytes.
final bytes = codec.encode('Hello, Solana!');
// bytes == [72, 101, 108, 108, 111, 44, 32, 83, 111, 108, 97, 110, 97, 33]

// Decode UTF-8 bytes back to a string.
final text = codec.decode(Uint8List.fromList([72, 101, 108, 108, 111]));
// text == 'Hello'

// Multi-byte characters are handled correctly.
final emoji = codec.encode('\u{1F680}'); // Rocket emoji
// emoji.length == 4 (UTF-8 encoding of a 4-byte character)
```

### Custom base-X encoding

Create codecs for arbitrary alphabets using `getBaseXCodec`:

```dart
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

// Create a base-2 (binary) codec.
final binaryCodec = getBaseXCodec('01');
final bytes = binaryCodec.encode('11111111'); // Uint8List [0xff]
final decoded = binaryCodec.decode(bytes);    // '11111111'

// Create a custom base-36 codec.
final base36Codec = getBaseXCodec('0123456789abcdefghijklmnopqrstuvwxyz');
```

### Custom base-X reslice encoding

For alphabets whose length is a power of 2, `getBaseXResliceCodec` is more efficient because it uses bit-slicing instead of BigInt arithmetic:

```dart
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

// Base-8 (octal) using reslice -- alphabet length is 8 = 2^3, bits = 3.
final octalCodec = getBaseXResliceCodec('01234567', 3);
final bytes = octalCodec.encode('777');
final decoded = octalCodec.decode(bytes);
```

### Null character utilities

Fixed-size string encodings often use null characters (`\u0000`) as padding. This package provides helpers:

```dart
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

// Remove null characters from a decoded string.
final cleaned = removeNullCharacters('hello\u0000\u0000\u0000');
// cleaned == 'hello'

// Pad a string with null characters to a fixed length.
final padded = padNullCharacters('hello', 10);
// padded == 'hello\u0000\u0000\u0000\u0000\u0000'
```

### Using with codec composition

String codecs are commonly combined with size prefixes or fixed-size constraints from `solana_kit_codecs_core`:

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

// Create a length-prefixed UTF-8 string codec.
// The string's byte length is encoded as a u32 prefix.
final prefixedUtf8 = addCodecSizePrefix(getUtf8Codec(), getU32Codec());

final bytes = prefixedUtf8.encode('Hello');
// bytes == [5, 0, 0, 0, 72, 101, 108, 108, 111]
//          ^--u32 len--^ ^---UTF-8 bytes---^

// Create a fixed-size UTF-8 string codec (always 32 bytes).
final fixedUtf8 = fixCodecSize(getUtf8Codec(), 32);
```

## API Reference

### Base encoders/decoders/codecs

| Function                                                         | Description                         |
| ---------------------------------------------------------------- | ----------------------------------- |
| `getBase10Encoder()` / `getBase10Decoder()` / `getBase10Codec()` | Base-10 (decimal) encoding          |
| `getBase16Encoder()` / `getBase16Decoder()` / `getBase16Codec()` | Base-16 (hexadecimal) encoding      |
| `getBase58Encoder()` / `getBase58Decoder()` / `getBase58Codec()` | Base-58 (Bitcoin alphabet) encoding |
| `getBase64Encoder()` / `getBase64Decoder()` / `getBase64Codec()` | Base-64 encoding                    |

### UTF-8

| Function                                                   | Description           |
| ---------------------------------------------------------- | --------------------- |
| `getUtf8Encoder()` / `getUtf8Decoder()` / `getUtf8Codec()` | UTF-8 string encoding |

### Generic base-X

| Function                                                                                                                     | Description                                                                |
| ---------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| `getBaseXEncoder(alphabet)` / `getBaseXDecoder(alphabet)` / `getBaseXCodec(alphabet)`                                        | Custom base-X encoding using BigInt arithmetic                             |
| `getBaseXResliceEncoder(alphabet, bits)` / `getBaseXResliceDecoder(alphabet, bits)` / `getBaseXResliceCodec(alphabet, bits)` | Custom base-X encoding using bit reslicing (for power-of-2 alphabet sizes) |

### Null character utilities

| Function                            | Description                                         |
| ----------------------------------- | --------------------------------------------------- |
| `removeNullCharacters(string)`      | Remove all `\u0000` characters from a string        |
| `padNullCharacters(string, length)` | Pad a string with `\u0000` to reach a target length |
