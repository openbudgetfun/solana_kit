# solana_kit_codecs_data_structures

[![pub package](https://img.shields.io/pub/v/solana_kit_codecs_data_structures.svg)](https://pub.dev/packages/solana_kit_codecs_data_structures)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_codecs_data_structures/latest/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Codecs for encoding and decoding composite data structures -- structs, arrays, tuples, maps, sets, enums, booleans, and more -- for Solana on-chain data.

This is a Dart port of [`@solana/codecs-data-structures`](https://github.com/anza-xyz/kit/tree/main/packages/codecs-data-structures) from the Solana TypeScript SDK.

## Installation

```yaml
dependencies:
  solana_kit_codecs_data_structures:
```

Since this package is part of the `solana_kit` Dart workspace, it is resolved automatically. For standalone use, point to the repository or use a path dependency.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_codecs_data_structures
- API reference: https://pub.dev/documentation/solana_kit_codecs_data_structures/latest/

## Usage

### Structs

Encode and decode named field structures (similar to Rust structs or C structs). Fields are serialized sequentially in the order they are declared.

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

// Define a struct with named fields.
final personCodec = getStructCodec([
  ('age', getU8Codec()),
  ('name', addCodecSizePrefix(getUtf8Codec(), getU32Codec())),
]);

// Encode a struct as a Map.
final bytes = personCodec.encode({
  'age': 30,
  'name': 'Alice',
});
// bytes == [30, 5, 0, 0, 0, 65, 108, 105, 99, 101]
//          ^age ^--name len--^ ^----name UTF-8----^

// Decode back to a Map.
final person = personCodec.decode(bytes);
// person == {'age': 30, 'name': 'Alice'}
```

### Arrays

Encode and decode lists of homogeneous values. By default, the array length is prefixed with a `u32` value.

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

// Default: u32-prefixed array of u8 values.
final arrayCodec = getArrayCodec(getU8Codec());
final bytes = arrayCodec.encode([10, 20, 30]);
// bytes == [3, 0, 0, 0, 10, 20, 30]
//          ^--u32 len--^ ^-items-^

final decoded = arrayCodec.decode(bytes);
// decoded == [10, 20, 30]
```

#### Array size options

Control how the array length is determined using `ArrayLikeCodecSize`:

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

// Fixed-size array (always exactly 3 items, no prefix).
final fixed = getArrayCodec(
  getU8Codec(),
  size: FixedArraySize(3),
);
fixed.encode([1, 2, 3]); // Uint8List [1, 2, 3] -- no length prefix

// Custom prefix (e.g., u16 instead of u32).
final u16Prefixed = getArrayCodec(
  getU8Codec(),
  size: PrefixedArraySize(getU16Codec()),
);
u16Prefixed.encode([1, 2, 3]); // Uint8List [3, 0, 1, 2, 3]

// Remainder: infer count from remaining bytes (fixed-size items only).
final remainder = getArrayCodec(
  getU8Codec(),
  size: RemainderArraySize(),
);
remainder.encode([1, 2, 3]); // Uint8List [1, 2, 3] -- no prefix
```

### Tuples

Encode and decode fixed-length heterogeneous lists. Unlike arrays, each position has its own codec:

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

// A tuple of (u8, u32, bool).
final tupleCodec = getTupleCodec([
  getU8Codec(),
  getU32Codec(),
  getBooleanCodec(),
]);

final bytes = tupleCodec.encode([255, 1000, true]);
// Encodes each item sequentially: [0xff, 0xe8, 0x03, 0x00, 0x00, 0x01]

final decoded = tupleCodec.decode(bytes);
// decoded == [255, 1000, true]
```

### Booleans

Encode `true` as `1` and `false` as `0`. By default, stored as a single `u8` byte:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

final boolCodec = getBooleanCodec();

boolCodec.encode(true);  // Uint8List [0x01]
boolCodec.encode(false); // Uint8List [0x00]

boolCodec.decode(Uint8List.fromList([1])); // true
boolCodec.decode(Uint8List.fromList([0])); // false
```

You can customize the underlying number codec:

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

// Store booleans as u32 (4 bytes).
final wideBool = getBooleanCodec(size: getU32Codec());
wideBool.encode(true); // Uint8List [0x01, 0x00, 0x00, 0x00]
```

### Nullable values

Encode optional values with a boolean prefix (0 = null, 1 = present):

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

final nullableU16 = getNullableCodec(getU16Codec());

// Encoding a present value.
nullableU16.encode(42);   // Uint8List [0x01, 0x2a, 0x00]
//                                     ^prefix ^--value--^

// Encoding null.
nullableU16.encode(null);  // Uint8List [0x00]
//                                      ^prefix (0 = null)

// Decoding.
nullableU16.decode(Uint8List.fromList([0x01, 0x2a, 0x00])); // 42
nullableU16.decode(Uint8List.fromList([0x00]));              // null
```

#### Zeroes none value

Use zeroes to represent null instead of omitting the value. This keeps the encoded size constant for fixed-size items:

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

final nullableU16 = getNullableCodec(
  getU16Codec(),
  noneValue: ZeroesNoneValue(),
);

nullableU16.encode(42);   // Uint8List [0x01, 0x2a, 0x00]
nullableU16.encode(null);  // Uint8List [0x00, 0x00, 0x00]
//                          prefix=0, then 2 bytes of zeroes
```

### Maps

Encode and decode `Map<K, V>` values as arrays of key-value pairs:

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

// Map<String, int> with u32-prefixed size.
final mapCodec = getMapCodec(
  addCodecSizePrefix(getUtf8Codec(), getU32Codec()),
  getU8Codec(),
);

final bytes = mapCodec.encode({'a': 1, 'b': 2});
final decoded = mapCodec.decode(bytes);
// decoded == {'a': 1, 'b': 2}
```

### Sets

Encode and decode `Set<T>` values as arrays with deduplication:

```dart
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

final setCodec = getSetCodec(getU8Codec());

final bytes = setCodec.encode({10, 20, 30});
final decoded = setCodec.decode(bytes);
// decoded == {10, 20, 30}
```

### Discriminated unions

Encode Rust-like enums where each variant is distinguished by a discriminator field (default: `'__kind'`):

```dart
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

// Define an enum with two variants.
final messageCodec = getDiscriminatedUnionCodec([
  // Variant 0: 'quit' -- no additional data.
  ('quit', getUnitCodec()),
  // Variant 1: 'move' -- has x and y fields.
  ('move', getStructCodec([
    ('x', getI32Codec()),
    ('y', getI32Codec()),
  ])),
]);

// Encode the 'quit' variant.
final quitBytes = messageCodec.encode({'__kind': 'quit'});
// quitBytes == [0x00]

// Encode the 'move' variant.
final moveBytes = messageCodec.encode({
  '__kind': 'move',
  'x': 10,
  'y': -5,
});
// moveBytes == [0x01, 0x0a, 0x00, 0x00, 0x00, 0xfb, 0xff, 0xff, 0xff]
//              ^disc ^-------x--------^ ^-------y--------^

// Decode.
final decoded = messageCodec.decode(moveBytes);
// decoded == {'__kind': 'move', 'x': 10, 'y': -5}
```

### Literal unions

Encode a value from a fixed set of variants as its index:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

final directionCodec = getLiteralUnionCodec(['north', 'south', 'east', 'west']);

directionCodec.encode('south'); // Uint8List [0x01] -- index 1
directionCodec.encode('west');  // Uint8List [0x03] -- index 3

directionCodec.decode(Uint8List.fromList([0x02])); // 'east'
```

### Raw unions

For cases where you need full control over variant selection (without a stored discriminator):

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

final unionCodec = getUnionCodec(
  [getU8Codec(), getU32Codec()],
  // Encode: select variant by value type.
  (Object? value) => (value as num) > 255 ? 1 : 0,
  // Decode: select variant by inspecting the byte array.
  (Uint8List bytes, int offset) => bytes.length - offset >= 4 ? 1 : 0,
);
```

### Bit arrays

Pack boolean arrays into compact bit representations (8 booleans per byte):

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

// 1 byte = 8 booleans.
final bitCodec = getBitArrayCodec(1);

final bytes = bitCodec.encode([true, false, true, false, false, false, false, true]);
// bytes == [0xa1] (10100001 in binary, MSB-first)

final decoded = bitCodec.decode(Uint8List.fromList([0xa1]));
// decoded == [true, false, true, false, false, false, false, true]

// Use backward mode for LSB-first ordering.
final bitCodecLsb = getBitArrayCodec(1, backward: true);
```

### Raw bytes

Encode and decode raw `Uint8List` data without transformation:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

final bytesCodec = getBytesCodec();

final data = Uint8List.fromList([1, 2, 3, 4, 5]);
final encoded = bytesCodec.encode(data);
// encoded == Uint8List [1, 2, 3, 4, 5]

final decoded = bytesCodec.decode(encoded);
// decoded == Uint8List [1, 2, 3, 4, 5]
```

### Constants

Encode a fixed byte sequence (ignores the input value) and verify it when decoding:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

final magicCodec = getConstantCodec(Uint8List.fromList([0xCA, 0xFE]));

// Always writes [0xCA, 0xFE].
final bytes = magicCodec.encode(null);

// Decoding verifies the bytes match. Throws if they don't.
magicCodec.decode(Uint8List.fromList([0xCA, 0xFE])); // OK
```

### Unit codec

A zero-size codec that encodes and decodes `void`. Useful for empty enum variants:

```dart
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

final unitCodec = getUnitCodec();
unitCodec.encode(null); // Uint8List [] (empty)
unitCodec.decode(Uint8List(0)); // null
```

### Hidden prefix and suffix

Embed hidden constant data before or after the main encoded value, without exposing it in the API:

```dart
import 'dart:typed_data';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

// Prepend a 2-byte magic number before the actual value.
final codec = getHiddenPrefixCodec(
  getU8Codec(),
  [getConstantCodec(Uint8List.fromList([0xCA, 0xFE]))],
);

final bytes = codec.encode(42);
// bytes == [0xCA, 0xFE, 0x2a]
//          ^--hidden--^ ^val^

final decoded = codec.decode(bytes);
// decoded == 42 (the hidden prefix is consumed but not returned)

// Similarly, getHiddenSuffixCodec appends hidden data after the value.
```

## API Reference

### Struct codecs

| Function                   | Description                                                |
| -------------------------- | ---------------------------------------------------------- |
| `getStructEncoder(fields)` | Encode a `Map<String, Object?>` from named field encoders  |
| `getStructDecoder(fields)` | Decode a `Map<String, Object?>` using named field decoders |
| `getStructCodec(fields)`   | Combined struct codec                                      |

### Array codecs

| Function                        | Description                               |
| ------------------------------- | ----------------------------------------- |
| `getArrayEncoder(item, {size})` | Encode a `List<T>` with configurable size |
| `getArrayDecoder(item, {size})` | Decode a `List<T>` with configurable size |
| `getArrayCodec(item, {size})`   | Combined array codec                      |

### Array size types

| Type                        | Description                                     |
| --------------------------- | ----------------------------------------------- |
| `PrefixedArraySize(prefix)` | Length stored as a number prefix (default: u32) |
| `FixedArraySize(n)`         | Fixed number of items, no prefix                |
| `RemainderArraySize()`      | Infer count from remaining bytes                |

### Tuple codecs

| Function                 | Description                                               |
| ------------------------ | --------------------------------------------------------- |
| `getTupleEncoder(items)` | Encode a `List<Object?>` with heterogeneous item encoders |
| `getTupleDecoder(items)` | Decode a `List<Object?>` with heterogeneous item decoders |
| `getTupleCodec(items)`   | Combined tuple codec                                      |

### Boolean codecs

| Function                    | Description                             |
| --------------------------- | --------------------------------------- |
| `getBooleanEncoder({size})` | Encode `bool` as a number (default: u8) |
| `getBooleanDecoder({size})` | Decode a number as `bool`               |
| `getBooleanCodec({size})`   | Combined boolean codec                  |

### Nullable codecs

| Function                                                   | Description                                    |
| ---------------------------------------------------------- | ---------------------------------------------- |
| `getNullableEncoder(item, {prefix, hasPrefix, noneValue})` | Encode nullable values with an optional prefix |
| `getNullableDecoder(item, {prefix, hasPrefix, noneValue})` | Decode nullable values                         |
| `getNullableCodec(item, {prefix, hasPrefix, noneValue})`   | Combined nullable codec                        |

### None value types

| Type                       | Description                                               |
| -------------------------- | --------------------------------------------------------- |
| `OmitNoneValue()`          | Null values are omitted (default)                         |
| `ZeroesNoneValue()`        | Null values are encoded as zeroes (fixed-size items only) |
| `ConstantNoneValue(bytes)` | Null values are encoded as a specific byte sequence       |

### Map codecs

| Function                            | Description                             |
| ----------------------------------- | --------------------------------------- |
| `getMapEncoder(key, value, {size})` | Encode `Map<K, V>` as key-value pairs   |
| `getMapDecoder(key, value, {size})` | Decode key-value pairs into `Map<K, V>` |
| `getMapCodec(key, value, {size})`   | Combined map codec                      |

### Set codecs

| Function                      | Description                   |
| ----------------------------- | ----------------------------- |
| `getSetEncoder(item, {size})` | Encode `Set<T>` as an array   |
| `getSetDecoder(item, {size})` | Decode an array into `Set<T>` |
| `getSetCodec(item, {size})`   | Combined set codec            |

### Discriminated union codecs

| Function                                                        | Description                                  |
| --------------------------------------------------------------- | -------------------------------------------- |
| `getDiscriminatedUnionEncoder(variants, {discriminator, size})` | Encode a map with a `'__kind'` discriminator |
| `getDiscriminatedUnionDecoder(variants, {discriminator, size})` | Decode a discriminated union                 |
| `getDiscriminatedUnionCodec(variants, {discriminator, size})`   | Combined discriminated union codec           |

### Literal union codecs

| Function                                   | Description                           |
| ------------------------------------------ | ------------------------------------- |
| `getLiteralUnionEncoder(variants, {size})` | Encode a value as its index in a list |
| `getLiteralUnionDecoder(variants, {size})` | Decode an index into a variant value  |
| `getLiteralUnionCodec(variants, {size})`   | Combined literal union codec          |

### Raw union codecs

| Function                                                        | Description                                  |
| --------------------------------------------------------------- | -------------------------------------------- |
| `getUnionEncoder(variants, getIndexFromValue)`                  | Encode using a user-defined variant selector |
| `getUnionDecoder(variants, getIndexFromBytes)`                  | Decode using a user-defined variant selector |
| `getUnionCodec(variants, getIndexFromValue, getIndexFromBytes)` | Combined union codec                         |

### Bit array codecs

| Function                               | Description                          |
| -------------------------------------- | ------------------------------------ |
| `getBitArrayEncoder(size, {backward})` | Encode `List<bool>` into packed bits |
| `getBitArrayDecoder(size, {backward})` | Decode packed bits into `List<bool>` |
| `getBitArrayCodec(size, {backward})`   | Combined bit array codec             |

### Bytes codecs

| Function            | Description                  |
| ------------------- | ---------------------------- |
| `getBytesEncoder()` | Encode raw `Uint8List` as-is |
| `getBytesDecoder()` | Decode raw `Uint8List` as-is |
| `getBytesCodec()`   | Combined bytes codec         |

### Constant codecs

| Function                    | Description                                 |
| --------------------------- | ------------------------------------------- |
| `getConstantEncoder(bytes)` | Always writes a fixed byte sequence         |
| `getConstantDecoder(bytes)` | Verifies and consumes a fixed byte sequence |
| `getConstantCodec(bytes)`   | Combined constant codec                     |

### Unit codecs

| Function           | Description                  |
| ------------------ | ---------------------------- |
| `getUnitEncoder()` | Zero-size encoder for `void` |
| `getUnitDecoder()` | Zero-size decoder for `void` |
| `getUnitCodec()`   | Combined unit codec          |

### Hidden prefix/suffix codecs

| Function                                            | Description                         |
| --------------------------------------------------- | ----------------------------------- |
| `getHiddenPrefixEncoder(encoder, prefixedEncoders)` | Prepend hidden data before encoding |
| `getHiddenPrefixDecoder(decoder, prefixedDecoders)` | Skip hidden prefix when decoding    |
| `getHiddenPrefixCodec(codec, prefixedCodecs)`       | Combined hidden prefix codec        |
| `getHiddenSuffixEncoder(encoder, suffixedEncoders)` | Append hidden data after encoding   |
| `getHiddenSuffixDecoder(decoder, suffixedDecoders)` | Skip hidden suffix when decoding    |
| `getHiddenSuffixCodec(codec, suffixedCodecs)`       | Combined hidden suffix codec        |
