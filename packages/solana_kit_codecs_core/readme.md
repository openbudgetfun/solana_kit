# solana_kit_codecs_core

Core codec interfaces and composition utilities for encoding and decoding Solana data structures in Dart.

This is a Dart port of [`@solana/codecs-core`](https://github.com/anza-xyz/kit/tree/main/packages/codecs-core) from the Solana TypeScript SDK.

## Installation

```yaml
dependencies:
  solana_kit_codecs_core:
```

Since this package is part of the `solana_kit` Dart workspace, it is resolved automatically. For standalone use, point to the repository or use a path dependency.

## Usage

### Core types: Encoder, Decoder, and Codec

The package provides three sealed class hierarchies for working with binary data:

- **`Encoder<T>`** -- Encodes a value of type `T` into a `Uint8List`.
- **`Decoder<T>`** -- Decodes a `Uint8List` into a value of type `T`.
- **`Codec<TFrom, TTo>`** -- Combines both encoding and decoding. `TFrom` is the type accepted for encoding (may be looser), while `TTo` is the type returned when decoding.

Each hierarchy has two concrete subtypes:

- **`FixedSizeEncoder<T>`** / **`FixedSizeDecoder<T>`** / **`FixedSizeCodec<TFrom, TTo>`** -- Always operates on a fixed number of bytes (`fixedSize`).
- **`VariableSizeEncoder<T>`** / **`VariableSizeDecoder<T>`** / **`VariableSizeCodec<TFrom, TTo>`** -- The byte length depends on the value.

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

// Create a simple fixed-size encoder for a single byte.
final myEncoder = FixedSizeEncoder<int>(
  fixedSize: 1,
  write: (value, bytes, offset) {
    bytes[offset] = value;
    return offset + 1;
  },
);

final encoded = myEncoder.encode(42);
// encoded == Uint8List.fromList([42])

// Create a matching decoder.
final myDecoder = FixedSizeDecoder<int>(
  fixedSize: 1,
  read: (bytes, offset) => (bytes[offset], offset + 1),
);

final decoded = myDecoder.decode(Uint8List.fromList([42]));
// decoded == 42
```

### Combining encoders and decoders

Use `combineCodec` to pair an `Encoder` and a `Decoder` into a `Codec`. Both must have compatible sizes (both fixed or both variable, with matching sizes).

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

final encoder = FixedSizeEncoder<int>(
  fixedSize: 1,
  write: (value, bytes, offset) {
    bytes[offset] = value;
    return offset + 1;
  },
);

final decoder = FixedSizeDecoder<int>(
  fixedSize: 1,
  read: (bytes, offset) => (bytes[offset], offset + 1),
);

final codec = combineCodec(encoder, decoder);
// codec is a FixedSizeCodec<int, int>

final bytes = codec.encode(255); // Uint8List [0xff]
final value = codec.decode(bytes); // 255
```

### Extracting encoders and decoders from codecs

Since `Codec` does not extend `Encoder` or `Decoder` (Dart does not support multiple inheritance of sealed classes), use `encoderFromCodec` and `decoderFromCodec` to extract them:

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

// Given some codec...
final codec = combineCodec(myEncoder, myDecoder);

// Extract an Encoder view.
final enc = encoderFromCodec(codec);
final encoded = enc.encode(42);

// Extract a Decoder view.
final dec = decoderFromCodec(codec);
final decoded = dec.decode(encoded);
```

### Transforming codecs

Use `transformEncoder`, `transformDecoder`, and `transformCodec` to map between types:

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

// Suppose we have a u8 encoder that encodes num values.
// We can transform it to accept bool values instead.
final boolEncoder = transformEncoder<num, bool>(
  u8Encoder,
  (bool value) => value ? 1 : 0,
);

final bytes = boolEncoder.encode(true); // Uint8List [0x01]

// Transform a decoder to map its output.
final boolDecoder = transformDecoder<int, bool>(
  u8Decoder,
  (int value, _, __) => value != 0,
);

final decoded = boolDecoder.decode(Uint8List.fromList([1])); // true
```

### Fixing codec size

Convert a variable-size codec into a fixed-size one with `fixEncoderSize`, `fixDecoderSize`, and `fixCodecSize`:

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

// Fix a variable-size encoder to always produce 32 bytes.
final fixed = fixEncoderSize(myVariableEncoder, 32);
// fixed.fixedSize == 32
// Shorter values are zero-padded, longer values are truncated.
```

### Adding size prefixes

Prefix the encoded data with its byte length using `addEncoderSizePrefix`, `addDecoderSizePrefix`, and `addCodecSizePrefix`:

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

// Add a u32 size prefix to a variable-size encoder.
final prefixed = addEncoderSizePrefix(myEncoder, u32Encoder);
// When encoding, the byte length of the encoded value is written first,
// followed by the encoded value itself.
```

### Adding sentinels

Delimit encoded values with a sentinel byte sequence using `addEncoderSentinel`, `addDecoderSentinel`, and `addCodecSentinel`:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

final sentinel = Uint8List.fromList([0xff, 0xff]);

// The encoder appends the sentinel after the encoded value.
final sentineled = addEncoderSentinel(myEncoder, sentinel);

// The decoder reads until the sentinel is found.
final sentineledDecoder = addDecoderSentinel(myDecoder, sentinel);
```

### Reversing bytes

Reverse the byte order of a fixed-size encoder, decoder, or codec:

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

// Reverse a fixed-size encoder (e.g., to switch endianness).
final reversed = reverseEncoder(myFixedEncoder);
```

### Offsetting and padding

Adjust the read/write offset before and after encoding/decoding:

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

// Add 4 bytes of left padding (zeroes before the encoded value).
final padded = padLeftEncoder(myEncoder, 4);

// Add 4 bytes of right padding (zeroes after the encoded value).
final paddedRight = padRightEncoder(myEncoder, 4);

// Use offsetEncoder for fine-grained control.
final offset = offsetEncoder(
  myEncoder,
  OffsetConfig(
    preOffset: (scope) => scope.preOffset + 2,
  ),
);
```

### Resizing codecs

Change the reported size of a codec without altering its read/write behavior:

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

// Increase the reported size by 8 bytes.
final resized = resizeEncoder(myEncoder, (size) => size + 8);
```

### Checking codec size

Use utility functions to inspect whether a codec is fixed-size or variable-size:

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

isFixedSize(myCodec);    // true if fixed-size
isVariableSize(myCodec); // true if variable-size

// Assert and throw if the expectation is not met.
assertIsFixedSize(myCodec);
assertIsVariableSize(myCodec);

// Get the encoded size of a specific value.
final size = getEncodedSize(myValue, myEncoder);
```

## API Reference

### Core types

| Type | Description |
|------|-------------|
| `Encoder<T>` | Sealed class for encoding values to bytes |
| `FixedSizeEncoder<T>` | Encoder with a fixed `fixedSize` |
| `VariableSizeEncoder<T>` | Encoder with dynamic size via `getSizeFromValue` |
| `Decoder<T>` | Sealed class for decoding bytes to values |
| `FixedSizeDecoder<T>` | Decoder with a fixed `fixedSize` |
| `VariableSizeDecoder<T>` | Decoder with dynamic size |
| `Codec<TFrom, TTo>` | Sealed class combining encoding and decoding |
| `FixedSizeCodec<TFrom, TTo>` | Codec with a fixed `fixedSize` |
| `VariableSizeCodec<TFrom, TTo>` | Codec with dynamic size |

### Composition functions

| Function | Description |
|----------|-------------|
| `combineCodec(encoder, decoder)` | Combine an `Encoder` and `Decoder` into a `Codec` |
| `encoderFromCodec(codec)` | Extract an `Encoder` from a `Codec` |
| `decoderFromCodec(codec)` | Extract a `Decoder` from a `Codec` |

### Transform functions

| Function | Description |
|----------|-------------|
| `transformEncoder(encoder, unmap)` | Map input type before encoding |
| `transformDecoder(decoder, map)` | Map output type after decoding |
| `transformCodec(codec, unmap, [map])` | Map both input and output types |

### Size manipulation

| Function | Description |
|----------|-------------|
| `fixEncoderSize(encoder, fixedBytes)` | Fix an encoder to a constant byte size |
| `fixDecoderSize(decoder, fixedBytes)` | Fix a decoder to a constant byte size |
| `fixCodecSize(codec, fixedBytes)` | Fix a codec to a constant byte size |
| `resizeEncoder(encoder, resize)` | Change the reported size of an encoder |
| `resizeDecoder(decoder, resize)` | Change the reported size of a decoder |
| `resizeCodec(codec, resize)` | Change the reported size of a codec |

### Size prefix

| Function | Description |
|----------|-------------|
| `addEncoderSizePrefix(encoder, prefix)` | Prefix encoded data with its byte length |
| `addDecoderSizePrefix(decoder, prefix)` | Read a size prefix before decoding |
| `addCodecSizePrefix(codec, prefix)` | Add size prefix to both encode and decode |

### Sentinel

| Function | Description |
|----------|-------------|
| `addEncoderSentinel(encoder, sentinel)` | Append a sentinel after encoding |
| `addDecoderSentinel(decoder, sentinel)` | Read until a sentinel when decoding |
| `addCodecSentinel(codec, sentinel)` | Add sentinel to both encode and decode |

### Offset and padding

| Function | Description |
|----------|-------------|
| `offsetEncoder(encoder, config)` | Adjust pre/post offset of an encoder |
| `offsetDecoder(decoder, config)` | Adjust pre/post offset of a decoder |
| `offsetCodec(codec, config)` | Adjust pre/post offset of a codec |
| `padLeftEncoder(encoder, offset)` | Add left (leading) zero padding |
| `padRightEncoder(encoder, offset)` | Add right (trailing) zero padding |
| `padLeftDecoder(decoder, offset)` | Skip left padding when decoding |
| `padRightDecoder(decoder, offset)` | Skip right padding when decoding |
| `padLeftCodec(codec, offset)` | Add left padding to both encode and decode |
| `padRightCodec(codec, offset)` | Add right padding to both encode and decode |

### Byte reversal

| Function | Description |
|----------|-------------|
| `reverseEncoder(encoder)` | Reverse bytes of a fixed-size encoder |
| `reverseDecoder(decoder)` | Reverse bytes of a fixed-size decoder |
| `reverseCodec(codec)` | Reverse bytes of a fixed-size codec |

### Utility functions

| Function | Description |
|----------|-------------|
| `getEncodedSize(value, encoder)` | Get the byte size of an encoded value |
| `isFixedSize(object)` | Check if a codec/encoder/decoder is fixed-size |
| `isVariableSize(object)` | Check if a codec/encoder/decoder is variable-size |
| `assertIsFixedSize(object)` | Assert fixed-size or throw |
| `assertIsVariableSize(object)` | Assert variable-size or throw |
| `createDecoderThatConsumesEntireByteArray(decoder)` | Ensure all bytes are consumed |
| `containsBytes(bytes, target, offset)` | Check if bytes contain a subsequence |
| `fixBytes(bytes, length)` | Pad or truncate bytes to a fixed length |
